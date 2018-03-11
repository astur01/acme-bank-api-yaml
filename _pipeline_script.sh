#!/bin/bash
set -e -o pipefail
cat > _customer_script.sh <<'EOF_CUSTOMER_SCRIPT'
#!/bin/bash
# your script here
git config --global user.email "astur01@hotmail.es"
git config --global user.name "astur01"
git checkout -b release/1.1
echo 'Content for release branch' >> release.txt
git add .
git commit -m "added to release/1.1"
git push origin release/1.1
version="release/1.1"
echo $version >> .target
echo $REMOTE_URL_REPO >> .remote
echo 'Fin de script...'
EOF_CUSTOMER_SCRIPT
if [ "$PIPELINE_DEBUG_SCRIPT" == "true" ]; then
current_time=$(echo $(($(date +%s%N)/1000000)))
fi
source _customer_script.sh
if [ "$PIPELINE_DEBUG_SCRIPT" == "true" ]; then
end_time=$(echo $(($(date +%s%N)/1000000)))
let "total_time=$end_time - $current_time"
echo "_DEBUG:USER_SCRIPT:$total_time"
current_time=
end_time=
total_time=
fi
cd "$WORKSPACE"
if [ -d "$ARCHIVE_DIR" ]; then
skip_artifact_upload=false
artifact_files_size=$(du -sm "$ARCHIVE_DIR" | tr -s [:space:] ' ' | cut -d ' ' -f 1)
artifact_files=$(find "$ARCHIVE_DIR" | wc -l)
if [ "$PIPELINE_DEBUG_SCRIPT" == "true" ]; then
echo _DEBUG:ARTIFACT_FILES_SIZE:$artifact_files_size
echo _DEBUG:ARTIFACT_FILES:$artifact_files
fi
if [ "$skip_artifact_upload" == "false" ]; then
if [ "$PIPELINE_DEBUG_SCRIPT" == "true" ]; then
current_time=$(echo $(($(date +%s%N)/1000000)))
fi
export_variable="-x _pipeline_script.sh -x _customer_script.sh -x _codestation_script.sh"
if test -f '.csignore'; then
while read -r line;
do
if test -n "$line"; then
if echo "$line" | grep -q '^[^\\]*$'; then
if echo "$line" | grep -q '^[0-9A-Za-z\/\.\-\_\*]*$'; then
export_variable="$export_variable -x $line"
fi
fi
fi
done < .csignore
else
export_variable="$export_variable -x /.git*"
fi
export ZIP_EXCLUDES="$export_variable"
CURL_VERBOSITY="--silent"
if [ "$PIPELINE_DEBUG_SCRIPT" == "true" ]; then CURL_VERBOSITY="-vvvv"; fi
echo "Preparing the build artifacts..."
curl $CURL_VERBOSITY --fail --retry 3 --retry-delay 5 --connect-timeout 10 --output _codestation_script.sh https://pipeline-artifact-repository-service.ng.bluemix.net:443/v3/up.sh
if [ $? == 0 ]; then
export PIPELINE_CODESTATION_URL="https://pipeline-artifact-repository-service.ng.bluemix.net:443"
export PIPELINE_ARCHIVE_ID=""
   sh _codestation_script.sh
else
   echo "An error occurred while attempting to download https://pipeline-artifact-repository-service.ng.bluemix.net:443/v3/up.sh"
   exit 1
fi
if [ "$PIPELINE_DEBUG_SCRIPT" == "true" ]; then
end_time=$(echo $(($(date +%s%N)/1000000)))
let "total_time=$end_time - $current_time"
echo "_DEBUG:UPLOAD_ARTIFACTS:$total_time"
current_time=
end_time=
total_time=
fi
fi
else
echo "Archive directory $ARCHIVE_DIR does not exist. Please check the name."
exit 1
fi
if [ "$PIPELINE_DEBUG_SCRIPT" == "true" ]; then
current_time=$(echo $(($(date +%s%N)/1000000)))
fi
/opt/IBM/pipeline/bin/ids-set-env.sh 'https://devops-api.ng.bluemix.net/v1/pipeline/notifications/stage_properties/4801540b-4d7e-4446-b024-ba003c9c7efa' 'aeced2eaf1a5602e97ada388c4a14a74.4422bcd39528a77ee2c020f6a70ab55542578252cc9c934dd73ebb2b9f3f57e48dd02192df66c8d67d1637e38c7a1c1ca9a1fb246d14874d32833863342f07dad9893678980791dfdc14ec50e31cf25f.e9d69ff3b44445f12384f7e840faa6b0f6cbc39e' "$IDS_OUTPUT_PROPS"
if [ "$PIPELINE_DEBUG_SCRIPT" == "true" ]; then
end_time=$(echo $(($(date +%s%N)/1000000)))
let "total_time=$end_time - $current_time"
echo "_DEBUG:UPLOAD_STAGE_PROPERTIES:$total_time"
current_time=
end_time=
total_time=
fi
