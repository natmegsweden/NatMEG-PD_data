#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Import raw (MaxFiltered) MEG data to remove metadata then save in same format for 
further BIDSifying. For passive movements task.
@author: mikkel
"""
import os
import os.path as op
import pandas as pd
import mne

# raw_path        = '/archive/20080_PD_EBRAINS/ORIGINAL/MEG';
raw_path        = '/archive/20079_parkinsons_longitudinal/MEG'
meg_path        = '/home/mikkel/PD_long/data_share/sourcedata'
subj_data_path  = '/archive/20080_PD_EBRAINS/ORIGINAL/subj_data'

#%% Filename exceptions
skip_subjs =  ['0572', '0578', '0715', '0716','0718','0739','0740']

exceptions = {
    '0525': 'passive_mc_avgtrans_tsss_corr95.fif',                  # To avoid reading old file
    '0536': 'passive_tsss_mc.fif'
    }

#%% Overwrite
overwrite=False

#%% Read data
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
        
    if subj in exceptions:
        tmpFiles = [f for f in os.listdir(subdir_raw) if exceptions[subj] in f]
        outFname = op.join(subdir_tmp, exceptions[subj][:-4]+'-raw.fif')

    else:            
        tmpFiles = [f for f in os.listdir(subdir_raw) if 'passive' in f and 'mc_avgtrans_tsss_corr95' in f]
        outFname = op.join(subdir_tmp, 'passive_mc_avgtrans_tsss_corr95-raw.fif')
        
    # print('Number of files = '+str(len(tmpFiles))+' for subj '+subj+' ('+str(ii)+')')

    # Only run if overwrite = True
    if op.exists(outFname) and not overwrite:
        continue
        
    # Create output folder
    if not op.exists(subdir_tmp):
        os.makedirs(subdir_tmp)

    # Read MEG data
    for jj, ff in enumerate(tmpFiles):
        if jj==0:
            raw = mne.io.read_raw_fif(op.join(subdir_raw, ff), on_split_missing='warn')
        else:
            raw.append(mne.io.read_raw(op.join(subdir_raw, ff), on_split_missing='warn'))

    # Anonymize
    raw.anonymize()
    #mne.io.anonymize_info(raw.info)
    raw.info['subject_info']['id'] = linkdata['anonym_id'][ii]
    #raw.info['proj_name'] = 'NatMEG-PD'
    raw.info['description'] = 'NatMEG-PD'

    # Select channels (remove unused MISC channels)
    accChname = ['MISC013', 'MISC014', 'MISC015']            
    raw.pick_types(meg=True, eog=True, ecg=True, ias=True, stim=True, syst=True, chpi=True, include=accChname)
    
    # Save
    print('Saving '+outFname)
    raw.save(outFname, overwrite=overwrite)

#END    