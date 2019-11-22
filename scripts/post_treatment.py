#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
    Catch-up TV & More
    Copyright (C) 2016  SylvainCecchetto

    This file is part of Catch-up TV & More.

    Catch-up TV & More is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Catch-up TV & More is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with Catch-up TV & More; if not, write to the Free Software Foundation,
    Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
"""

import os
import pytz
import xmltv
import datetime
from pprint import pprint

# The date format used in XMLTV (the %Z will go away in 0.6)
date_format = '%Y%m%d%H%M%S %Z'
date_format_notz = '%Y%m%d%H%M%S'

WD = os.path.dirname(os.path.abspath(__file__))

countries = {
    'fr': {
        'raw_fp': os.path.join(WD, '../raw/tv_guide_fr_telerama.xml'),
        'dst_full_fp': os.path.join(WD, '../tv_guide_fr.xml'),
        'dst_1_day_fp': os.path.join(WD, '../tv_guide_fr_{}.xml'),
        'tz': 'Europe/Paris',
        'channels_list': [],
        'programmes_list:': [],
        'data_list': []
    },
    'be': {
        'raw_fp': os.path.join(WD, '../raw/tv_guide_be_telerama.xml'),
        'dst_full_fp': os.path.join(WD, '../tv_guide_be.xml'),
        'dst_1_day_fp': os.path.join(WD, '../tv_guide_be_{}.xml'),
        'tz': 'Europe/Paris',
        'channels_list': [],
        'programmes_list:': [],
        'data_list': []
    },
    'uk': {
        'raw_fp': os.path.join(WD, '../raw/tv_guide_uk_tvguide.xml'),
        'dst_full_fp': os.path.join(WD, '../tv_guide_uk.xml'),
        'dst_1_day_fp': os.path.join(WD, '../tv_guide_uk_{}.xml'),
        'tz': 'Europe/London',
        'channels_list': [],
        'programmes_list:': [],
        'data_list': []
    }

}


for country_code, country_infos in countries.items():
    print('* Processing of {} country:'.format(country_code))

    # Parse channels and programmes in the raw xmltv file
    country_infos['channels_list'] = xmltv.read_channels(open(country_infos['raw_fp'], 'r'))
    country_infos['programmes_list'] = xmltv.read_programmes(open(country_infos['raw_fp'], 'r'))
    country_infos['data_list'] = xmltv.read_data(open(country_infos['raw_fp'], 'r'))

    # Replace datetime by the UTC one
    for programme in country_infos['programmes_list']:
        for elt in ['start', 'stop']:
            s = programme[elt]

            # Remove timezone part to get %Y%m%d%H%M%S format
            s = s.split(' ')[0]

            # Get the naive datetime object
            d = datetime.datetime.strptime(s, date_format_notz)

            # Add correct timezone
            tz = pytz.timezone(country_infos['tz'])
            d = tz.localize(d)

            # Convert to UTC timezone
            utc_tz = pytz.UTC
            d = d.astimezone(utc_tz)

            # Finally replace the datetime with the UTC one
            s = d.strftime(date_format_notz)
            # print('Replace {} by {}'.format(programme[elt], s))
            programme[elt] = s

    # Write the corrected full xmltv file
    print('\t- Write corrected full xmltv file in {}'.format(os.path.basename(country_infos['dst_full_fp'])))
    w = xmltv.Writer(
        source_info_url=country_infos['data_list']['source-info-url']
    )
    for c in country_infos['channels_list']:
        w.addChannel(c)
    for p in country_infos['programmes_list']:
        w.addProgramme(p)
    with open(country_infos['dst_full_fp'], 'w') as f:
        w.write(f, pretty_print=True)

    # Write one day xmltv files
    print('\t- Write one day xmltv files:')
    today = datetime.datetime.now()
    for offset in range(-1, 6):
        delta = datetime.timedelta(days=offset)
        date = today + delta
        date_s = date.strftime("%Y%m%d")
        fp = country_infos['dst_1_day_fp'].format(date_s)
        print('\t\t* Write day {} in {}'.format(date_s, os.path.basename(fp)))
        w = xmltv.Writer(
            source_info_url=country_infos['data_list']['source-info-url']
        )
        for c in country_infos['channels_list']:
            w.addChannel(c)
        for p in country_infos['programmes_list']:
            start_s = p['start'][0:8]
            stop_s = p['stop'][0:8]
            if start_s == date_s or stop_s == date_s:
                w.addProgramme(p)
        with open(fp, 'w') as f:
            w.write(f, pretty_print=True)


print('* Merge all country tv guides in tv_guide_all.xml')

w = xmltv.Writer()

for country_code, country_infos in countries.items():
    for c in country_infos['channels_list']:
        w.addChannel(c)

for country_code, country_infos in countries.items():
    for p in country_infos['programmes_list']:
        w.addProgramme(p)

with open(os.path.join(WD, '../tv_guide_all.xml'), 'w') as f:
    w.write(f, pretty_print=True)
