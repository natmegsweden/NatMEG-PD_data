#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Merge various metadata files into one database.
@author: mikkel
"""
import pandas as pd
import numpy as np

# Get general data 
# metadata = pd.read_csv('/home/mikkel/PD_long/subj_data/metadata.csv')
# metadata['anonym_id'] = [format(ii, '03d') for ii in metadata['anonym_id']]

general_data = pd.read_csv('/home/mikkel/PD_long/subj_data/subj_data_anonymised.csv', delimiter=',')
general_data['MEG_dateY'] = [int(dd[1:5]) for dd in general_data.MEG_date]

# %% Bin age data
general_data['agebin'] = 0

for ii, ax in enumerate(general_data.Age):
    if 41 <= ax and ax <= 45:
        general_data['agebin'][ii] = '41-45'
    elif 46 <= ax and ax <= 50:
        general_data['agebin'][ii] = '46-50'
    elif 51 <= ax and ax <= 55:
        general_data['agebin'][ii] = '51-55'
    elif 56 <= ax and ax <= 60:
        general_data['agebin'][ii] = '56-60'      
    elif 61 <= ax and ax <= 65:
        general_data['agebin'][ii] = '61-65'
    elif 66 <= ax and ax <= 70:
        general_data['agebin'][ii] = '66-70'
    elif 71 <= ax and ax <= 75:
        general_data['agebin'][ii] = '71-75'
    elif 76 <= ax and ax <= 80:
        general_data['agebin'][ii] = '76-80';      

# %% Get link data
linkdata = pd.read_csv('/home/mikkel/PD_long/subj_data/linkdata.csv')
linkdata['anonym_id'] = [format(ii, '03d') for ii in linkdata['anonym_id']]

# Handedness
hand_data  = pd.read_csv('/home/mikkel/PD_long/subj_data/handedness.csv')

# LEDD + Disease dur
ledd_data  = pd.read_csv('/home/mikkel/PD_long/subj_data/ptns_medication_anonymised.csv', delimiter=',', usecols=[0, 1, 2], nrows=67)

# HY stage + UPDRS + UPDRS subscales
updrs_data = pd.read_csv('/home/mikkel/PD_long/subj_data/UPDRS_PD_MEG_2020.csv', delimiter=';')
updrs_data.rename(columns = {'H_Y_STAGE ':'H_Y_STAGE'}, inplace = True)
updrs_data['H_Y_STAGE'] = updrs_data['H_Y_STAGE'].replace(to_replace='NR', value=np.NaN)
updrs_data['H_Y_STAGE'] = updrs_data['H_Y_STAGE'].replace(to_replace='UR', value=np.NaN)

# %% Merge data and select only relevant coulmns
tmp1 = pd.merge(linkdata, general_data, left_on='subjects', right_on='Study_id', how='left')
tmp2 = pd.merge(tmp1, updrs_data, left_on='Study_id', right_on='Study_id', how='left')
tmp3 = pd.merge(tmp2, ledd_data, left_on='Study_id', right_on='NATID', how='left')
tmp4 = pd.merge(tmp3, hand_data, left_on='Study_id', right_on='Study_id', how='left')
tmp4['disease_dur'] = tmp4.MEG_dateY - tmp4.Initial_diagnosis
tmp4['group'] = tmp4['Type']

metadata = tmp4[['anonym_id', 'group', 'Sex', 'hand', 'agebin', 
                 'LEDD', 'disease_dur', 'H_Y_STAGE', 'UPDRS_TOTAL', 
                 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'MoCA', 'FAB', 'BDI']]

# %% Save
metadata.to_csv('/home/mikkel/PD_long/subj_data/metadata.csv', index=False)
tmp4.to_csv('/home/mikkel/PD_long/subj_data/mergeddata.csv', index=False)

# END