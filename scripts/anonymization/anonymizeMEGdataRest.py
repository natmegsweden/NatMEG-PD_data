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

raw_path        = '/archive/20079_parkinsons_longitudinal/MEG'
meg_path        = '/home/mikkel/PD_long/data_share/sourcedata'
subj_data_path  = '/archive/20080_PD_EBRAINS/ORIGINAL/subj_data'

skip_subjs =  []

# Filename exceptions
exceptions = {
    '0582':'rest_ec_tsss.fif',              # No cHPI
    '0604':'rest_ec_tsss_mc.fif',           # Error due to too many 'autobad' channels. Manual MaxFilter.
    }

#%% Overwrite
overwrite=True

#%% Read data
linkdata = pd.read_csv(op.join(subj_data_path, 'linkdata.csv'))

#%% RUN
for ii, ss in enumerate(linkdata['subjects']):
    subj = '0'+str(ss)
    print(subj)
    
    if subj in skip_subjs:
        continue

    # I/O
    subdir_raw = op.join(raw_path, linkdata['subject_date'][ii])
    subdir_tmp = op.join(meg_path, linkdata['subject_date'][ii])
        
    if subj in exceptions:
        tmpFiles = [f for f in os.listdir(subdir_raw) if exceptions[subj] in f]
    else:            
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
    raw.anonymize()
    raw.info['subject_info']['id'] = linkdata['anonym_id'][ii]
    raw.info['description'] = 'NatMEG-PD'

    # Select channels (remove unused MISC channels)
    accChname = ['MISC013', 'MISC014', 'MISC015']            
    raw.pick_types(meg=True, eog=True, ecg=True, ias=True, stim=True, syst=True, chpi=True, include=accChname)
    
    # Save
    print('Saving '+outFname)
    raw.save(outFname, overwrite=overwrite)
    del raw
    
#END    