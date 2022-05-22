#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun May 22 15:14:45 2022
@author: mikkel
"""

import os
import os.path as op
import pandas as pd
import mne
import datetime
from mne_bids import write_raw_bids, read_raw_bids, BIDSPath, print_dir_tree

# raw_path        = '/archive/20080_PD_EBRAINS/ORIGINAL/MEG';
raw_path        = '/archive/20079_parkinsons_longitudinal/MEG'
meg_path        = '/home/mikkel/PD_long/data_share/sourcedata'
subj_data_path  = '/archive/20080_PD_EBRAINS/ORIGINAL/subj_data'
bids_root       = '/home/mikkel/PD_long/data_share/temp'

skip_subjs =  []

#%% Overwrite
overwrite=False

#%% Read data
alldata = pd.read_csv(op.join(subj_data_path, 'metadata.csv'))
linkdata = pd.read_csv(op.join(subj_data_path, 'linkdata.csv'))
filenames = pd.read_csv(op.join(subj_data_path, 'filenames.csv'))

#%% RUN
for ii, ss in enumerate(linkdata['subjects']):
    subj = '0'+str(ss)
    sid  = str(linkdata['anonym_id'][ii]).zfill(3)
    print(subj)
    
    if subj in skip_subjs:
        continue

    # I/O
    subdir_raw = op.join(raw_path, linkdata['subject_date'][ii] )
    subdir_tmp = op.join(meg_path, linkdata['subject_date'][ii] )

    outFname = op.join(subdir_tmp, filenames['empty_fname'][ii])
    
    # Only run if overwrite = True
    if op.exists(outFname) and not overwrite:
        continue
    
    # Create output folder
    if not op.exists(subdir_tmp):
        os.makedirs(subdir_tmp)

    # Read MEG data
    raw = mne.io.read_raw(op.join(subdir_raw, filenames['empty_fname'][ii]))
    
    # Anonymize
    mne.io.anonymize_info(raw.info)
    raw.info['subject_info']['id'] = linkdata['anonym_id'][ii]
    # raw.info['proj_name'] = 'NatMEG-PD'
    raw.info['description'] = 'NatMEG-PD'

    # Select channels (remove unused MISC channels)
    accChname = ['MISC013', 'MISC014', 'MISC015']
    raw.pick_types(meg=True, eog=True, ecg=True, ias=True, stim=True, syst=True, chpi=True, include=accChname)
    raw.crop(tmin=0, tmax=120)
    
    # Save
    print('Saving '+outFname)
    raw.save(outFname, overwrite=overwrite)
    # raw = mne.io.read_raw(outFname)
    
    # time_change = datetime.timedelta(days=ii)
    # raw.set_meas_date(raw.info['meas_date'] + time_change)
    # er_date = raw.info['meas_date'].strftime('%Y%m%d')

    # # er_bids_path = BIDSPath(subject=str(linkdata['anonym_id'][ii]), session=str(1), task='noise', processing='tsss', root=bids_root)
    # er_bids_path = BIDSPath(subject='emptyroom', session=er_date, task='noise', root=bids_root)
    # write_raw_bids(raw, er_bids_path, overwrite=overwrite)


    # Save
    