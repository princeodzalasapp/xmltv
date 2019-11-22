#!/usr/bin/env bash

# Move in the scripts directory
BASEDIR=$(dirname "$0")
cd $BASEDIR
BASEDIR=$(pwd) # Only to get absolute path and not relative path

# Hack HOME env var to use local .xmltv folder
HOME="$BASEDIR"

UK_GUIDE_CONFIG="./uk/tv_grab_uk_tvguide_test.conf"


tv_grab_uk () {
    days=$1
    offset=$2
    output=$3
    ./uk/tv_grab_uk_tvguide --config-file "$UK_GUIDE_CONFIG" --days "$days" --offset "$offset" --output "$output"
}

tv_grab_uk 2 1 ../test_uk.xml