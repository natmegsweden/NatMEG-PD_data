#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Summaries of metadata
@author: mikkel
"""
import pandas as pd

dat = pd.read_csv('/home/mikkel/PD_long/subj_data/mergeddata.csv')

dat['Type'].value_counts()

pd.crosstab(dat['Type'], dat['Sex'])

dat[['LEDD','UPDRS_TOTAL','disease_dur']].describe()

dat.groupby("Type")['BDI','MoCA','FAB','Age'].mean()
dat.groupby("Type")['BDI','MoCA','FAB','Age'].std()
dat.groupby("Type")['BDI','MoCA','FAB','Age'].min()
dat.groupby("Type")['BDI','MoCA','FAB','Age'].max()



