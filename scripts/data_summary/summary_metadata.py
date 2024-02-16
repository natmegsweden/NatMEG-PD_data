#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Summaries of metadata
@author: mikkel
For information about NatMEG-PD please refer to the data descriptor:

Vinding, M. C., Eriksson, A., Comarovschii, I., Waldthaler, J., Manting, C. L., 
 	 Oostenveld, R., Ingvar, M., Svenningsson, P., & Lundqvist, D. (2024). The 
   Swedish National Facility for Magnetoencephalography Parkinson's disease dataset.
   Scientific Data, 11(1), 150. https://doi.org/10.1038/s41597-024-02987-w

The NatMEG-PD data is available through at the following location:
   https://search.kg.ebrains.eu/instances/d55146e8-fc86-44dd-95db-7191fdca7f30
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
