#!/bin/bash
# your script here
git config --global user.email "astur01@hotmail.es"
git config --global user.name "astur01"
git checkout -b release/1.2
echo 'Content for release branch' >> release12.txt
git add .
git commit -m "added to release/1.2"
git push origin release/1.2
version="release/1.2"
echo $version >> .target
echo $REMOTE_URL_REPO >> .remote
file=$(cat /proc/1/cgroup)
echo "cgroup = $file"
echo 'Fin de script...'
