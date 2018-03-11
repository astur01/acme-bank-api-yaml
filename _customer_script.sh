#!/bin/bash
# your script here
git config --global user.email "astur01@hotmail.es"
git config --global user.name "astur01"
git checkout -b release/1.0
echo 'Content for release branch' >> release.txt
git add .
git commit -m "added to release/1.0"
git push origin release/1.0
version="release/1.0"
echo $version >> .target
remoteUrl =$(git remote get-url origin)
echo $remoteUrl >> .remote
