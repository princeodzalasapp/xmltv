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
        'dst_fp': os.path.join(WD, '../tv_guide_fr{}.xml'),
        'tz': 'Europe/Paris'
    },
    'fr_tnt': {
        'raw_fp': os.path.join(WD, '../raw/tv_guide_fr_telerama.xml'),
        'dst_fp': os.path.join(WD, '../tv_guide_fr_tnt{}.xml'),
        'tz': 'Europe/Paris',
        'channels_to_add': [
            'C192.api.telerama.fr',
            'C4.api.telerama.fr',
            'C80.api.telerama.fr',
            'C34.api.telerama.fr',
            'C45.api.telerama.fr',
            'C118.api.telerama.fr',
            'C111.api.telerama.fr',
            'C4.api.telerama.fr',
            'C445.api.telerama.fr',
            'C119.api.telerama.fr',
            'C195.api.telerama.fr',
            'C1404.api.telerama.fr',
            'C444.api.telerama.fr',
            'C446.api.telerama.fr',
            'C234.api.telerama.fr',
            'C78.api.telerama.fr',
            'C481.api.telerama.fr',
            'C226.api.telerama.fr',
            'C458.api.telerama.fr',
            'C482.api.telerama.fr',
            'C160.api.telerama.fr',
            'C1401.api.telerama.fr',
            'C1403.api.telerama.fr',
            'C1402.api.telerama.fr',
            'C1400.api.telerama.fr',
            'C1399.api.telerama.fr',
            'C112.api.telerama.fr',
            'C2111.api.telerama.fr'
        ]
    },
    'be': {
        'raw_fp': os.path.join(WD, '../raw/tv_guide_be_telerama.xml'),
        'dst_fp': os.path.join(WD, '../tv_guide_be{}.xml'),
        'tz': 'Europe/Paris'
    },
    'uk': {
        'raw_fp': os.path.join(WD, '../raw/tv_guide_uk_tvguide.xml'),
        'dst_fp': os.path.join(WD, '../tv_guide_uk{}.xml'),
        'tz': 'Europe/London'
    },
    'it': {
        'raw_fp': os.path.join(WD, '../raw/tv_guide_it.xml'),
        'dst_fp': os.path.join(WD, '../tv_guide_it{}.xml'),
        'tz': 'Europe/Rome'
    }

}


for country_code, country_infos in countries.items():
    print('* Processing of {} country:'.format(country_code))

    # Parse channels, data and programmes in the raw xmltv file
    try:
        # country_infos['channels_list'] = xmltv.read_channels(open(country_infos['raw_fp'], 'r'))
        # country_infos['programmes_list_local_datetime'] = xmltv.read_programmes(open(country_infos['raw_fp'], 'r'))
        # country_infos['data_list'] = xmltv.read_data(open(country_infos['raw_fp'], 'r'))
        channels_l = xmltv.read_channels(open(country_infos['raw_fp'], 'r'))
        programmes_local_datetime_l = xmltv.read_programmes(open(country_infos['raw_fp'], 'r'))
        data_l = xmltv.read_data(open(country_infos['raw_fp'], 'r'))
    except Exception:
        continue

    # XMLTV data stays untouched
    country_infos['data_l'] = data_l

    # If any filter on channels exists, remove unwanted channels
    if 'channels_to_add' in country_infos:
        country_infos['channels_l'] = []
        for channel in channels_l:
            if 'id' in channel and channel['id'] in country_infos['channels_to_add']:
                country_infos['channels_l'].append(channel)
    else:
        country_infos['channels_l'] = channels_l

    
    # Programmes
    country_infos['programmes_l'] = []
    country_infos['programmes_local_datetime_l'] = []

    for programme in programmes_local_datetime_l:
        if 'start' in programme and 'stop' in programme:
            if 'channels_to_add' in country_infos:
                if 'channel' in programme and programme['channel'] in country_infos['channels_to_add']:
                    country_infos['programmes_l'].append(dict(programme))
                    country_infos['programmes_local_datetime_l'].append(dict(programme))
            else:
                country_infos['programmes_l'].append(dict(programme))
                country_infos['programmes_local_datetime_l'].append(dict(programme))
    
    # Replace local datetime by UTC datetime for programmes entries
    for programme in country_infos['programmes_l']:
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

    # Write corrected full xmltv files
    for fp_prefix in ['', '_local']:
        dst_fp = country_infos['dst_fp'].format(fp_prefix)
        print('\t- Write corrected full xmltv file in {}'.format(os.path.basename(dst_fp)))
        w = xmltv.Writer(
            source_info_url=country_infos['data_l']['source-info-url']
        )
        
        # Add channels
        for c in country_infos['channels_l']:
            w.addChannel(c)
        
        # Add programmes
        if fp_prefix == '_local':
            for p in country_infos['programmes_local_datetime_l']:
                w.addProgramme(p)
        else:
            for p in country_infos['programmes_l']:
                w.addProgramme(p)

        # Write XMLTV file
        with open(dst_fp, 'w') as f:
            w.write(f, pretty_print=True)

    # Write one day xmltv files
    print('\t- Write one day xmltv files:')
    today = datetime.datetime.now()
    for fp_prefix in ['', '_local']:
        for offset in range(-1, 6):
            delta = datetime.timedelta(days=offset)
            date = today + delta
            date_s = date.strftime("%Y%m%d")
            dst_fp = country_infos['dst_fp'].format(fp_prefix + '_' + date_s)
            print('\t\t* Write day {} in {}'.format(date_s, os.path.basename(dst_fp)))
            w = xmltv.Writer(
                source_info_url=country_infos['data_l']['source-info-url']
            )
            
            # Add channels
            for c in country_infos['channels_l']:
                w.addChannel(c)
            
            # Add programmes
            if fp_prefix == '_local':
                programmes_l = country_infos['programmes_local_datetime_l']
            else:
                programmes_l = country_infos['programmes_l']
            for p in programmes_l:
                start_s = p['start'][0:8]
                stop_s = p['stop'][0:8]
                if start_s == date_s or stop_s == date_s:
                    w.addProgramme(p)
            with open(dst_fp, 'w') as f:
                w.write(f, pretty_print=True)


print('* Merge all country tv guides in tv_guide_all.xml')

w = xmltv.Writer()

for country_code, country_infos in countries.items():
    if country_code == 'fr_tnt':
        continue
    if 'channels_l' in country_infos:
        for c in country_infos['channels_l']:
            w.addChannel(c)

for country_code, country_infos in countries.items():
    if country_code == 'fr_tnt':
        continue
    if 'programmes_l' in country_infos:
        for p in country_infos['programmes_l']:
            w.addProgramme(p)

with open(os.path.join(WD, '../tv_guide_all.xml'), 'w') as f:
    w.write(f, pretty_print=True)

print('* Merge all country tv guides in tv_guide_all_local.xml')

w = xmltv.Writer()

for country_code, country_infos in countries.items():
    if country_code == 'fr_tnt':
        continue
    if 'channels_l' in country_infos:
        for c in country_infos['channels_l']:
            w.addChannel(c)

for country_code, country_infos in countries.items():
    if country_code == 'fr_tnt':
        continue
    if 'programmes_local_datetime_l' in country_infos:
        for p in country_infos['programmes_local_datetime_l']:
            w.addProgramme(p)

with open(os.path.join(WD, '../tv_guide_all_local.xml'), 'w') as f:
    w.write(f, pretty_print=True)
