#!/usr/bin/env bash

# Move in the scripts directory
BASEDIR=$(dirname "$0")
cd $BASEDIR
BASEDIR=$(pwd) # Only to get absolute path and not relative path

now=$(date +"%d/%m/%Y %H:%M:%S-%Z")

BRANCH="master"
FR_GUIDE_CONFIG="./tv_grab_fr_telerama/tv_grab_fr_telerama_fr_config.txt"
BE_GUIDE_CONFIG="./tv_grab_fr_telerama/tv_grab_fr_telerama_be_config.txt"
UK_GUIDE_CONFIG="./tv_grab_uk_tvguide/tv_grab_uk_tvguide.conf"

# BRANCH="dev"
# FR_GUIDE_CONFIG="./tv_grab_fr_telerama/tv_grab_fr_telerama_fr_config_test.txt"
# BE_GUIDE_CONFIG="./tv_grab_fr_telerama/tv_grab_fr_telerama_be_config_test.txt"
# UK_GUIDE_CONFIG="./tv_grab_uk_tvguide/tv_grab_uk_tvguide_test.conf"

force_pull () {
    git fetch --all
    git reset --hard "origin/$BRANCH"
}

push () {
    git add --all
    git commit -m "Auto update TV guides ($now)"
    git push
}

update_raw_7_days_guides () {
    # FR guide
    rm ../raw/tv_guide_fr_telerama.xml
    ./tv_grab_fr_telerama/tv_grab_fr_telerama --config-file "$FR_GUIDE_CONFIG" --days 7 --offset -1 --output ../raw/tv_guide_fr_telerama.xml

    # BE guide
    rm ../raw/tv_guide_be_telerama.xml
    ./tv_grab_fr_telerama/tv_grab_fr_telerama --config-file "$BE_GUIDE_CONFIG" --days 7 --offset -1 --output ../raw/tv_guide_be_telerama.xml

    # UK guide
    rm ../raw/tv_guide_uk_tvguide.xml
    ./tv_grab_uk_tvguide/tv_grab_uk_tvguide --config-file "$UK_GUIDE_CONFIG" --days 7 --offset -1 --output ../raw/tv_guide_uk_tvguide.xml
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

echo "- Remove xmltv files"
rm ../*.xml

echo "- Update raw 7 days guides (tv_guide_XX.xml files in raw fodler)"
# Hack HOME env var to use local .xmltv folder
OLD_HOME="$HOME"
HOME="$BASEDIR"
update_raw_7_days_guides
HOME="$OLD_HOME"

echo "- Use python script to post treat tv guides (UTC time, split, merge, ...)"
./post_treatment.py

echo "- Add log file if needed"
move_log_file

echo -e "- Push changes"
push

echo -e "- Changes have been pushed --> exit"
exit 0
