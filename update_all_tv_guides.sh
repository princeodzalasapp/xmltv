#!/usr/bin/env bash

# Move in the script base directory
BASEDIR=$(dirname "$0")
cd $BASEDIR

now=$(date +"%d/%m/%Y %H:%M:%S-%Z")

#BRANCH="master"
BRANCH="dev"

#FR_GUIDE_CONFIG="./fr/tv_grab_fr_config.txt"
FR_GUIDE_CONFIG="./fr/tv_grab_fr_config_test.txt"

#BE_GUIDE_CONFIG="./be/tv_grab_be_config.txt"
BE_GUIDE_CONFIG="./be/tv_grab_be_config_test.txt"

force_pull () {
    git fetch --all
    git reset --hard "origin/$BRANCH"
}

push () {
    git add --all
    git commit -m "Auto update TV guides ($now)"
    git push
}

tv_grab_fr () {
    days=$1
    offset=$2
    output=$3
    ./fr/tv_grab_fr --config-file "$FR_GUIDE_CONFIG" --days "$days" --offset "$offset" --output "$output"
}

tv_grab_be () {
    days=$1
    offset=$2
    output=$3
    ./be/tv_grab_be --config-file "$BE_GUIDE_CONFIG" --days "$days" --offset "$offset" --output "$output"
}

update_7_days_guides () {
    # FR guide
    rm tv_guide_fr.xml
    tv_grab_fr 7 -1 ./tv_guide_fr.xml

    # BE guide
    rm tv_guide_be.xml
    tv_grab_be 7 -1 ./tv_guide_be.xml

    # ALL guide
    tv_sort --by-channel --output tv_guide_fr_sorted.xml tv_guide_fr.xml
    tv_sort --by-channel --output tv_guide_be_sorted.xml tv_guide_be.xml
    rm tv_guide_all.xml
    tv_merge -i tv_guide_fr_sorted.xml -m tv_guide_be_sorted.xml -o tv_guide_all.xml
    rm tv_guide_fr_sorted.xml
    rm tv_guide_be_sorted.xml
}

update_2_days_zip_guides () {
    # FR guide
    rm tv_guide_fr_lite.zip
    tv_grab_fr 2 -1 ./tv_guide_fr_lite.xml
    zip tv_guide_fr_lite.zip tv_guide_fr_lite.xml
    rm tv_guide_fr_lite.xml

    # BE guide
    rm tv_guide_be_lite.zip
    tv_grab_be 2 -1 ./tv_guide_be_lite.xml
    zip tv_guide_be_lite.zip tv_guide_be_lite.xml
    rm tv_guide_be_lite.xml
}

remove_old_guides () {
    for i in {3..40}
    do
        old_date=$(date +%Y%m%d --date="-${i} day")
        find . -type f -name '*${old_date}*' -delete
    done
}

update_1_day_guides () {
    # Remove old files (older than 3 days)
    remove_old_guides

    offsets=("-1" "+0" "+1" "+2" "+3" "+4" "+5")
    for i in "${offsets[@]}"; 
    do
        currentdate=$(date +%Y%m%d --date="${i} day")
        
        # FR guide
        file_name_xml="./tv_guide_fr_${futuredate}.xml"
        if [ ! -f $file_name_xml ]; then
            tv_grab_fr 1 "$i" "./tv_guide_fr_${currentdate}.xml"
        fi

        # BE guide
        file_name_xml="./tv_guide_be_${futuredate}.xml"
        if [ ! -f $file_name_xml ]; then
            tv_grab_be 1 "$i" "./tv_guide_be_${currentdate}.xml"
        fi
    done
}



move_log_file () {
    # If this script was executed with the
    # command './update_all_tv_guides.sh 2>&1 | tee /tmp/xmltv_log.txt'
    if test -f "/tmp/xmltv_log.txt"; then
        mv "/tmp/xmltv_log.txt" "log.txt"
    fi
}

echo "- Start script at $now"

echo "- To avoid any git conflict we do a force pull first"
force_pull

echo "- Update 7 days guides (tv_guide_XX.xml files)"
update_7_days_guides

# To remove later
echo "- Udpate 2 days zip guides (tv_guide_XX_lite.zip files)"
update_2_days_zip_guides

echo "- Update 1 day guides (tv_guide_XX_XXXXXXXX.xml files)"
update_1_day_guides

echo "- Add log file if needed"
move_log_file

echo -e "- Push changes"
push

echo -e "- Changes have been pushed --> exit"
exit 0
