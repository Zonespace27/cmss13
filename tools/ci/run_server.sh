#!/bin/bash
set -euo pipefail

MAP=$1

echo Testing $MAP

tools/deploy.sh ci_test
mkdir ci_test/data

#set the map
cp maps/$MAP.json ci_test/data/next_map.json
cp maps/templates/space.json ci_test/data/next_ship.json

cd ci_test
DreamDaemon colonialmarines.dmb -close -trusted -verbose -params "log-directory=ci"
cd ..
cat ci_test/data/logs/ci/clean_run.lk


cat ci_test/data/logs/ci/clean_run.lk
if [[ ! -f ci_test/code_coverage.xml ]] ; then
    echo 'File "code_coverage.xml" is not there, aborting.'
    exit 1
fi

#unflatten
#sed -i 's/!/\//g' ci_test/code_coverage.xml
#fix the !DOCTYPE
sed -i 's/<\/DOCTYPE/<!DOCTYPE/g' ci_test/code_coverage.xml
