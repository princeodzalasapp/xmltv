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
import xmltv
import pickle


def serialize_xmltv(xmltv_fp, pickle_fp):
    if os.path.exists(xmltv_fp):
        programmes = xmltv.read_programmes(open(xmltv_fp, 'r'))
        with open(pickle_fp, 'wb') as f:
            pickle.dump(programmes, f, protocol=2)


tv_guides = [
    ('tv_guide_fr_lite.xml', 'tv_guide_fr_lite.pkl'),
    ('tv_guide_be_lite.xml', 'tv_guide_be_lite.pkl')
]

for tv_guide in tv_guides:
    serialize_xmltv(tv_guide[0], tv_guide[1])
