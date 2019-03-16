#!/usr/bin/env bash

BASEDIR=$(dirname "$0")

echo -e "- Script directory: $BASEDIR --> Let's move to this directory"

cd $BASEDIR
cwd=$(pwd)

echo -e ""
echo -e "- Current workning directory: $cwd"

echo -e "- To avoid any git conflict we do a force pull first\n"
git fetch --all
git reset --hard origin/master




echo -e "\n# Update tv_guide_fr.xml\n"
./tv_grab_fr --config-file tv_grab_fr_config.txt --days 2 --ch_prefix "" --ch_postfix "" --output ./tv_guide_fr.xml



exit 0
