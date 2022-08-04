#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copy warped MRI to the proper BIDS directory.
@author: mikkel
"""
import os 
import os.path as op
import shutil
import pandas as pd

overwrite = 0
nomri_org = []
nomri_ano = []

# %% Folders
bids_path= '/home/mikkel/PD_long/data_share/BIDS_data'
raw_path  = '/home/mikkel/PD_long/data_share/mri_warp'

# %% Make Derivates dir
drv_path = op.join(bids_path, 'derivatives', 'warpimg')
if not op.exists(drv_path):
    os.makedirs(drv_path)

# %% Get linkdata
linkdata = pd.read_csv('/home/mikkel/PD_long/subj_data/linkdata.csv')
linkdata['anonym_id'] = [format(ii, '03d') for ii in linkdata['anonym_id']]
linkdata['subjects'] = [format(ii, '04d') for ii in linkdata['subjects']]

# %% Copy data
for ii, subjid in enumerate(linkdata.anonym_id):
    origid = linkdata.subjects[ii]
    
    infile = op.join(raw_path, origid, origid+'_mri_warptmp.nii')
    
    out_path = op.join(drv_path, 'sub-'+subjid, 'anat')
    outfile = op.join(out_path, 'sub-'+subjid+'_desc-warpimg.nii')
    
    if not op.exists(infile):
        nomri_org += [origid]
        nomri_ano += [subjid]
        continue
    
    if op.exists(outfile) and not overwrite:
        print('Output exist for subj '+subjid)
        continue
    
    if not op.exists(out_path):
        os.makedirs(out_path)
        
    shutil.copy(infile, outfile)

#END