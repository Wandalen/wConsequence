#! /bin/bash
set -o errexit
#set -o pipefail
#set -o verbose

#npm install -g jsdoc

WAS_DIR=$PWD
BASE_DIR=$(dirname $0)
cd $BASE_DIR

  rm -rf ./doc/reference/*
  npm -g install jsdoc
  jsdoc --recurse --verbose --configure doc.json

cd $WAS_DIR
