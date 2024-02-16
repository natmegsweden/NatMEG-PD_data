#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Get summaries of head movement in scanner per group.
@author: mikkel

For information about NatMEG-PD please refer to the data descriptor:

Vinding, M. C., Eriksson, A., Comarovschii, I., Waldthaler, J., Manting, C. L., 
 	 Oostenveld, R., Ingvar, M., Svenningsson, P., & Lundqvist, D. (2024). The 
   Swedish National Facility for Magnetoencephalography Parkinson's disease dataset.
   Scientific Data, 11(1), 150. https://doi.org/10.1038/s41597-024-02987-w

The NatMEG-PD data is available through at the following location:
   https://search.kg.ebrains.eu/instances/d55146e8-fc86-44dd-95db-7191fdca7f30
"""
import mne
import os.path as op
import numpy
import pandas as pd
import os

#%% 
bidsroot = '/archive/20080_PD_EBRAINS/EBRAINS/BIDS_data'
dat = pd.read_table(op.join(bidsroot, 'participants.tsv'))

raw_path        = '/archive/20079_parkinsons_longitudinal/MEG'
meg_path        = '/home/mikkel/PD_long/data_share/sourcedata'
subj_data_path  = '/archive/20080_PD_EBRAINS/ORIGINAL/subj_data'

# Filename exceptions
exceptions = {
    '0582':'rest_ec_tsss.fif',              # No cHPI
    '0604':'rest_ec_tsss_mc.fif',           # Error due to too many 'autobad' channels. Manual MaxFilter.
    }

startTrigger = 1
stopTrigger  = 64

linkdata = pd.read_csv(op.join(subj_data_path, 'linkdata.csv'))

total_move = [0]*len(dat.participant_id)
avg_move = [0]*len(dat.participant_id)

# for ii, subj in enumerate(dat.participant_id):
for ii, ss in enumerate(linkdata['subjects']):
    subj = '0'+str(ss)
    print(subj)
    
    if subj == '0582':
        total_move[ii] = float('nan')
        avg_move[ii] = float('nan')
        continue
    
    # I/O
    subdir_raw = op.join(raw_path, linkdata['subject_date'][ii])
        
    if subj in exceptions:
        tmpFiles = [f for f in os.listdir(subdir_raw) if exceptions[subj] in f]
    else:            
        tmpFiles = [f for f in os.listdir(subdir_raw) if 'rest_ec_mc_avgtrans_tsss_corr95' in f]
    
    inFile = tmpFiles[0]
    
    # Read MEG data
    raw = mne.io.read_raw(op.join(subdir_raw, inFile))
    eve = mne.find_events(raw, stim_channel='STI101', initial_event=True)
    
    # Trigger exceptions
    if subj == '0333':                    # Missing triggers
        startSam = 20000+raw.first_samp
        stopSam = 180102+startSam       
    elif subj in ['0322','0523','0524','0525','0529']:
        startSam = eve[eve[:,2] == startTrigger,0][0]
        stopSam = startSam+180102     
    elif subj in ['0548','0583']:                 # No start trigger. Start trigger val is stop trigger.
        stopSam = eve[eve[:,2] == startTrigger,0][0]
        startSam = stopSam-180102                                     
    elif subj == '0590':                 # No start trigger.
        startSam = raw.first_samp+1000             
        stopSam = startSam+180102
    elif subj == '0605':                 # Triggers numbers
        startSam = eve[eve[:,2] == 14593,0][0]
        stopSam = eve[eve[:,2] == 14656,0][0]
    elif subj == '0615':                 # No triggers.
        startSam = raw.first_samp+10000             
        stopSam = startSam+180102
    else:
        startSam = eve[eve[:,2] == startTrigger,0][0]
        stopSam = eve[eve[:,2] == stopTrigger,0][0]

    raw.crop(tmin=(startSam - raw.first_samp ) / raw.info['sfreq'], tmax=(stopSam - raw.first_samp ) / raw.info['sfreq'])
    
    quat, times = raw.pick_types(chpi=True).get_data(return_times=True)
    
    qT = numpy.vstack((times, quat)).transpose()
    # fig = mne.viz.plot_head_positions(qT, mode='traces', show=False)#, info=info)
    
    d1 = quat[0:3,0:-2]
    d2 = quat[0:3,1:-1]
        
    dnorm = numpy.sqrt(numpy.sum((d1-d2)**2, axis=0))
    dcum = numpy.cumsum(dnorm)
    
    avg = max(dcum)/(max(times)-min(times))
        
    text = 'Moved a cummulative total of %.2f cm during the session\nTotal recording time: %.2f min. (%.1f s)\nAverage movement: %.2f mm/s\n'
    print(text % (max(dcum)*100, max(times)/60, max(times), avg*1000))
    
    avg_move[ii] = avg*1000         # mm/s
    total_move[ii] = max(dcum)*100  # cm

#%% stat
import scipy.stats as stats
import numpy as np

df = pd.DataFrame({'Group':dat.group, 'move':total_move, 'avgmove':avg_move})
df = df.dropna()

med =  df.groupby(['Group']).apply(lambda x: np.median(x['avgmove']))
men =  df.groupby(['Group']).apply(lambda x: np.mean(x['avgmove']))
std =  df.groupby(['Group']).apply(lambda x: np.std(x['avgmove']))

U, p = stats.mannwhitneyu(df['move'][df['Group']=='Control'], df['move'][df['Group']=='Patient'])
# t, p = stats.ttest_ind(df['move'][df['Group']=='Control'], df['move'][df['Group']=='Patient'], equal_var=False)
# r, p = stats.ranksums(df['move'][df['Group']=='Control'], df['move'][df['Group']=='Patient'])

#%% Make plot
import seaborn as sns
import matplotlib.pyplot as plt

fig = plt.figure(figsize=(4, 5))
custom_params = {"axes.spines.right": False, "axes.spines.top": False, "figure.figsize":(5, 5)}
sns.set_theme(style='white', rc=custom_params)
# plt.ylabel('Average movement (mm/s)', weight='bold')
fig = sns.swarmplot(x='Group', y='avgmove', data=df, dodge=False, size=6, hue='Group', legend=False)
fig.set_ylabel('Average movement (mm/s)', weight='bold')
fig.set_xlabel('Group', weight='bold')
zz = fig.get_figure()
zz.tight_layout()
zz.savefig("/home/mikkel/PD_long/data_share/figures/move.png", dpi=600) 

#END
