#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Merge various metadata files into one database.
@author: mikkel
"""
import pandas as pd
import numpy as np

# Get general data 
metadata = pd.read_csv('/home/mikkel/PD_long/subj_data/metadata.csv')
metadata['anonym_id'] = [format(ii, '03d') for ii in metadata['anonym_id']]

general_data = pd.read_csv('/home/mikkel/PD_long/subj_data/subj_data_anonymised.csv', delimiter=',')
general_data['MEG_dateY'] = [int(dd[1:5]) for dd in general_data.MEG_date]

linkdata = pd.read_csv('/home/mikkel/PD_long/subj_data/linkdata.csv')
linkdata['anonym_id'] = [format(ii, '03d') for ii in linkdata['anonym_id']]

# Handedness
hand_data  = pd.read_csv('/home/mikkel/PD_long/subj_data/handedness.csv')

# LEDD + Disease dur
ledd_data  = pd.read_csv('/home/mikkel/PD_long/subj_data/ptns_medication_anonymised.csv', delimiter=';', usecols=[0, 1, 2], nrows=67)

# HY stage + UPDRS + UPDRS subscales
updrs_data = pd.read_csv('/home/mikkel/PD_long/subj_data/UPDRS_PD_MEG_2020.csv', delimiter=';')
updrs_data.rename(columns = {'H_Y_STAGE ':'H_Y_STAGE'}, inplace = True)
updrs_data['H_Y_STAGE'] = updrs_data['H_Y_STAGE'].replace(to_replace='NR', value=np.NaN)
updrs_data['H_Y_STAGE'] = updrs_data['H_Y_STAGE'].replace(to_replace='UR', value=np.NaN)

# Merge data and select only relevant coulmns
tmp1 = pd.merge(general_data, ledd_data, left_on='Study_id', right_on='NATID', how='left')
tmp2 = pd.merge(tmp1, updrs_data, left_on='Study_id', right_on='Study_id', how='left')
tmp3 = pd.merge(tmp2, linkdata, left_on='Study_id', right_on='subjects', how='left')
tmp4 = pd.merge(tmp3, hand_data, left_on='Study_id', right_on='Study_id', how='left')
tmp4['disease_dur'] = tmp4.MEG_dateY - tmp4.Initial_diagnosis

newdat = tmp4[['anonym_id', 'hand', 'LEDD', 'disease_dur', 'H_Y_STAGE', 'UPDRS_TOTAL', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7']]

metadata2 = pd.merge(metadata, newdat)
alldata = tmp4.drop('anonym_id', axis=1)

# Save
metadata2.to_csv('/home/mikkel/PD_long/subj_data/metadata.csv', index=False)
alldata.to_csv('/home/mikkel/PD_long/subj_data/mergeddata.csv', index=False)
