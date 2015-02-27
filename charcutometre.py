#!/bin/env python
# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import

import csv
import logging
import re

log = logging.getLogger(__name__)

CSV_IN = 'charcutometre/cantons_complexes.csv'
CSV_OUT = 'charcutometre/cantons_complexes_plus.csv'
JORF = 'charcutometre/{0}.txt'

RE_CANTON = r'Le canton n° (?P<no>\d+) (Saint-Pierre-3) comprend'

RE_SPACE = re.compile(r'\,\s[^\d]')

with open(CSV_IN) as csvfile, open(CSV_OUT, 'w', newline='') as out:
    reader = csv.DictReader(csvfile, delimiter=';')
    fieldnames = reader.fieldnames + ['count', 'doublons']
    writer = csv.DictWriter(out, delimiter=';', fieldnames=fieldnames)
    writer.writeheader()
    for row in reader:
        with open(JORF.format(row['jorf'])) as jorf:
            line = jorf.readlines()[int(row['canton']) - 1]

            # Count comas
            row['count'] = len(RE_SPACE.findall(line))

            # Count doublons
            parts = line.split(', ')
            if parts:
                parts = parts[1:]
                dedoubloned = set(parts)
                row['doublons'] = len(parts) - len(dedoubloned)
            else:
                row['doublons'] = 0

            writer.writerow(row)
            # print('' )
            # if m:
            #     print(m.groups())
