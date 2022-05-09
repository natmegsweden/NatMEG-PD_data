#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Import raw (MaxFiltered) MEG data to remove metadata then save in same format for 
further BIDSifying.
@author: mikkel
"""
import os
import os.path as op
import pandas as pd
import mne

raw_path        = '/archive/20080_PD_EBRAINS/ORIGINAL/MEG';
meg_path        = '/home/mikkel/PD_long/data_share/sourcedata';
subj_data_path  = '/home/mikkel/PD_long/subj_data/';

skip_subjs =  ['0582', '0604']

#%% Overwrite
overwrite=False

#%% Read data
alldata = pd.read_csv(op.join(subj_data_path, 'metadata.csv'))
linkdata = pd.read_csv(op.join(subj_data_path, 'linkdata.csv'))

#%%
for ii, ss in enumerate(linkdata['subjects']):
    subj = '0'+str(ss)
    sid  = str(linkdata['anonym_id'][ii]).zfill(3)
    print(subj)
    
    if subj in skip_subjs:
        continue

    # I/O
    subdir_raw = op.join(raw_path, linkdata['subject_date'][ii] )
    subdir_tmp = op.join(meg_path, linkdata['subject_date'][ii] )
        
    tmpFiles = [f for f in os.listdir(subdir_raw) if 'rest_ec_mc_avgtrans_tsss_corr95' in f]
    inFile = tmpFiles[0]
    outFname = op.join(subdir_tmp, inFile[:-4]+'-raw.fif')
    
    # Only run if overwrite = True
    if op.exists(outFname) and not overwrite:
        continue
    
    # Create output folder
    if not op.exists(subdir_tmp):
        os.makedirs(subdir_tmp)

    # Read MEG data
    raw = mne.io.read_raw(op.join(subdir_raw, inFile))
    
    # Anonymize
    mne.io.anonymize_info(raw.info)
    raw.info['subject_info']['id'] = linkdata['anonym_id'][ii]
    raw.info['proj_name'] = 'NatMEG-PD'
    raw.info['description'] = 'NatMEG-PD'

    # Select channels (remove unused MISC channels)
    accChname = ['MISC013', 'MISC014', 'MISC015']            
    raw.pick_types(meg=True, eog=True, ecg=True, ias=True, stim=True, syst=True, chpi=True, include=accChname)
    
    # Save
    print('Saving '+outFname)
    raw.save(outFname, overwrite=overwrite)

#END    