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


echo -e "\n# Update tv_guide_all.xml\n"
tv_sort --by-channel --output tv_guide_fr_sorted.xml tv_guide_fr.xml
tv_sort --by-channel --output tv_guide_be_sorted.xml tv_guide_be.xml
tv_merge -i tv_guide_fr_sorted.xml -m tv_guide_be_sorted.xml -o tv_guide_all.xml
rm tv_guide_fr_sorted.xml
rm tv_guide_be_sorted.xml

now=$(date +"%d/%m/%Y")

git add --all
git commit -m "$Auto update TV guides ($now)"
git push
echo -e "\t* Changes have been pushed"


exit 0
