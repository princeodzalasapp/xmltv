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
./fr/tv_grab_fr --config-file ./fr/tv_grab_fr_config.txt --days 7 --ch_prefix "" --ch_postfix "" --output ./tv_guide_fr.xml


echo -e "\n# Update tv_guide_be.xml\n"
./be/tv_grab_be --config-file ./be/tv_grab_be_config.txt --days 7 --ch_prefix "" --ch_postfix "" --output ./tv_guide_be.xml


now=$(date +"%d/%m/%Y")

git add --all
git commit -m "$Auto update TV guides ($now)"
git push
echo -e "\t* Changes have been pushed"


exit 0
