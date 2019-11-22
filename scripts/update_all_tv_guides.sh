#!/usr/bin/env bash

# Move in the scripts directory
BASEDIR=$(dirname "$0")
cd $BASEDIR
BASEDIR=$(pwd) # Only to get absolute path and not relative path

# Hack HOME env var to use local .xmltv folder
HOME="$BASEDIR"

now=$(date +"%d/%m/%Y %H:%M:%S-%Z")

# BRANCH="master"
# FR_GUIDE_CONFIG="./fr/tv_grab_fr_config.txt"
# BE_GUIDE_CONFIG="./be/tv_grab_be_config.txt"
# UK_GUIDE_CONFIG="./uk/tv_grab_uk_tvguide.conf"

BRANCH="dev"
FR_GUIDE_CONFIG="./fr/tv_grab_fr_config_test.txt"
BE_GUIDE_CONFIG="./be/tv_grab_be_config_test.txt"
UK_GUIDE_CONFIG="./uk/tv_grab_uk_tvguide_test.conf"

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

tv_grab_uk () {
    days=$1
    offset=$2
    output=$3
    ./uk/tv_grab_uk_tvguide --config-file "$UK_GUIDE_CONFIG" --days "$days" --offset "$offset" --output "$output"
}

update_raw_7_days_guides () {
    # FR guide
    rm ../raw/tv_guide_fr.xml
    tv_grab_fr 7 -1 ../raw/tv_guide_fr.xml

    # BE guide
    rm ../raw/tv_guide_be.xml
    tv_grab_be 7 -1 ../raw/tv_guide_be.xml

    # UK guide
    rm ../raw/tv_guide_uk.xml
    tv_grab_uk 7 -1 ../raw/tv_guide_uk.xml
}


move_log_file () {
    # If this script was executed with the
    # command './update_all_tv_guides.sh 2>&1 | tee /tmp/xmltv_log.txt'
    if test -f "/tmp/xmltv_log.txt"; then
        mv "/tmp/xmltv_log.txt" "log.txt"
    fi
}

echo "- Start script at $now in $BASEDIR"

echo "- To avoid any git conflict we do a force pull first"
force_pull

echo "- Update raw 7 days guides (tv_guide_XX.xml files in raw fodler)"
update_raw_7_days_guides

# To remove later
echo "- Use python script to post treat tv guides (UTC time, split, merge, ...)"
python3 post_treatment.py

echo "- Add log file if needed"
move_log_file

echo -e "- Push changes"
push

echo -e "- Changes have been pushed --> exit"
exit 0
