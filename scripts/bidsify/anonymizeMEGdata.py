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

#%% Overwrite
overwrite=True

#%% Read data
alldata = pd.read_csv(op.join(subj_data_path, 'metadata.csv'))
linkdata = pd.read_csv(op.join(subj_data_path, 'linkdata.csv'))

#%%
for ii, ss in enumerate(linkdata['subjects']):
    subj = '0'+str(ss)
    sid  = str(linkdata['anonym_id'][ii]).zfill(3)
    print(subj)

    # I/O
    subdir_raw = op.join(raw_path, linkdata['subject_date'][ii] )
    subdir_tmp = op.join(meg_path, 'sub-'+sid)
    outFname = op.join(subdir_tmp)
    
    if not op.exists(subdir_tmp):
        os.makedirs(subdir_tmp)
        
    tmpFiles = [f for f in os.listdir(subdir_raw) if 'rest_ec_mc_avgtrans_tsss_corr95' in f]
    outFname = op.join(subdir_tmp, tmpFiles[0])

    # Read MEG data
    raw = mne.io.read_raw(op.join(subdir_raw, tmpFiles[0]))
    
    # Anonymize
    mne.io.anonymize_info(raw.info)
    raw.info['subject_info']['id'] = linkdata['anonym_id'][ii]
    raw.info['proj_name'] = 'NatMEG-PD'
    raw.info['description'] = 'NatMEG-PD'

    # Select channels (remove unused MISC channels)
    accChname = ['MISC013', 'MISC014', 'MISC015']            
    raw.pick_types(meg=True, eog=True, ecg=True, ias=True, stim=True, syst=True, chpi=True, include=accChname)
    
    # Save
    raw.save(outFname, overwrite=overwrite)


#END    