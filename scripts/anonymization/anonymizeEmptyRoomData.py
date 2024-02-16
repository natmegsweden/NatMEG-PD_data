#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun May 22 15:14:45 2022
@author: mikkel

For information about NatMEG-PD please refer to the data descriptor:

Vinding, M. C., Eriksson, A., Comarovschii, I., Waldthaler, J., Manting, C. L., 
 	 Oostenveld, R., Ingvar, M., Svenningsson, P., & Lundqvist, D. (2024). The 
   Swedish National Facility for Magnetoencephalography Parkinson's disease dataset.
   Scientific Data, 11(1), 150. https://doi.org/10.1038/s41597-024-02987-w

The NatMEG-PD data is available through at the following location:
	https://search.kg.ebrains.eu/instances/d55146e8-fc86-44dd-95db-7191fdca7f30

"""
import os
import os.path as op
import pandas as pd
import mne

raw_path        = '/archive/20079_parkinsons_longitudinal/MEG'
meg_path        = '/home/mikkel/PD_long/data_share/sourcedata'
subj_data_path  = '/archive/20080_PD_EBRAINS/ORIGINAL/subj_data'

skip_subjs =  []

#%% Overwrite
overwrite=True

#%% Read data
linkdata = pd.read_csv(op.join(subj_data_path, 'linkdata.csv'))
filenames = pd.read_csv(op.join(subj_data_path, 'filenames.csv'))
fname_dict = dict(zip(filenames['subjects'], filenames['empty_fname']))

#%% RUN
for ii, ss in enumerate(linkdata['subjects']):
    subj = '0'+str(ss)
    sid  = str(linkdata['anonym_id'][ii]).zfill(3)
    print(subj)
    
    if subj in skip_subjs:
        continue

    # I/O
    subdir_raw = op.join(raw_path, linkdata['subject_date'][ii])
    subdir_tmp = op.join(meg_path, linkdata['subject_date'][ii])

    outFname = op.join(subdir_tmp, fname_dict[ss])
    
    # Only run if overwrite = True
    if op.exists(outFname) and not overwrite:
        continue
    
    # Create output folder
    if not op.exists(subdir_tmp):
        os.makedirs(subdir_tmp)

    # Read MEG data
    raw = mne.io.read_raw(op.join(subdir_raw, fname_dict[ss]))
    
    # Anonymize
    mne.io.anonymize_info(raw.info)
    raw.info['subject_info']['id'] = linkdata['anonym_id'][ii]
    # raw.info['proj_name'] = 'NatMEG-PD'
    raw.info['description'] = 'NatMEG-PD'

    # Select channels (remove unused MISC channels)
    accChname = ['MISC013', 'MISC014', 'MISC015']
    raw.pick_types(meg=True, eog=True, ecg=True, emg=True, ias=True, stim=True, syst=True, chpi=True, include=accChname)
    try:
        raw.crop(tmin=0, tmax=120)
    except:
        print('No cropping')
    
    # Save
    print('Saving '+outFname)
    raw.save(outFname, overwrite=overwrite)
    del raw

#END    
