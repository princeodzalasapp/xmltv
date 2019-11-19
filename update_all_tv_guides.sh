#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
cd $BASEDIR
cwd=$(pwd)
LOGFILE=/tmp/xmltv_log.txt

now=$(date +"%d/%m/%Y %H:%M:%S-%Z")
echo -e "- Start script at $now\n" > ${LOGFILE}

echo -e "- To avoid any git conflict we do a force pull first\n" >> ${LOGFILE}
git fetch --all 2>&1 | tee -a ${LOGFILE}
git reset --hard origin/master 2>&1 | tee -a ${LOGFILE}

echo -e "\n# Update tv_guide_fr.xml\n" >> ${LOGFILE}
rm tv_guide_fr.xml
./fr/tv_grab_fr --config-file ./fr/tv_grab_fr_config.txt --days 7 --offset -1 --output ./tv_guide_fr.xml 2>&1 | tee -a ${LOGFILE}

echo -e "\n# Update tv_guide_be.xml\n" >> ${LOGFILE}
rm tv_guide_be.xml
./be/tv_grab_be --config-file ./be/tv_grab_be_config.txt --days 7 --offset -1 --output ./tv_guide_be.xml 2>&1 | tee -a ${LOGFILE}

echo -e "\n# Update tv_guide_all.xml\n" >> ${LOGFILE}
tv_sort --by-channel --output tv_guide_fr_sorted.xml tv_guide_fr.xml 2>&1 | tee -a ${LOGFILE}
tv_sort --by-channel --output tv_guide_be_sorted.xml tv_guide_be.xml 2>&1 | tee -a ${LOGFILE}
rm tv_guide_all.xml
tv_merge -i tv_guide_fr_sorted.xml -m tv_guide_be_sorted.xml -o tv_guide_all.xml 2>&1 | tee -a ${LOGFILE}
rm tv_guide_fr_sorted.xml
rm tv_guide_be_sorted.xml

echo -e "\n# Update tv_guide_fr_lite.zip\n" >> ${LOGFILE}
rm tv_guide_fr_lite.zip
./fr/tv_grab_fr --config-file ./fr/tv_grab_fr_config.txt --days 2 --offset -1 --output ./tv_guide_fr_lite.xml 2>&1 | tee -a ${LOGFILE}
zip tv_guide_fr_lite.zip tv_guide_fr_lite.xml
rm tv_guide_fr_lite.xml

echo -e "\n# Update tv_guide_be_lite.zip\n" >> ${LOGFILE}
rm tv_guide_be_lite.zip
./be/tv_grab_be --config-file ./be/tv_grab_be_config.txt --days 2  --offset -1 --output ./tv_guide_be_lite.xml 2>&1 | tee -a ${LOGFILE}
zip tv_guide_be_lite.zip tv_guide_be_lite.xml
rm tv_guide_be_lite.xml

mv $LOGFILE $cwd/log.txt

git add --all
git commit -m "Auto update TV guides ($now)"
git push
echo -e "\t* Changes have been pushed"

exit 0
