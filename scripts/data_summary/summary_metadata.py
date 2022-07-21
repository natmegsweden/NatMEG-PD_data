#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Summaries of metadata
@author: mikkel
"""
import pandas as pd

# Read data
dat = pd.read_csv('/home/mikkel/PD_long/subj_data/mergeddata.csv')

# Data summaries
dat['Type'].value_counts()

pd.crosstab(dat['Type'], dat['Sex'])

dat[['LEDD','UPDRS_TOTAL','disease_dur']].describe()

dat.groupby("Type")['BDI','MoCA','FAB','Age'].mean()
dat.groupby("Type")['BDI','MoCA','FAB','Age'].std()
dat.groupby("Type")['BDI','MoCA','FAB','Age'].min()
dat.groupby("Type")['BDI','MoCA','FAB','Age'].max()


# Missing data
dat2 = pd.read_csv('/home/mikkel/PD_long/data_share/BIDS_data/participants.tsv', sep="\t")

dat2.describe()

dat2[dat2["group"]=="Patient"].isna().sum()
