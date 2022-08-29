# README

The README is usually the starting point for researchers using your data
and serves as a guidepost for users of your data. A clear and informative
README makes your data much more usable.

In general you can include information in the README that is not captured by some other
files in the BIDS dataset (dataset_description.json, events.tsv, ...).

It can also be useful to also include information that might already be
present in another file of the dataset but might be important for users to be aware of
before preprocessing or analysing the data.

If the README gets too long you have the possibility to create a `/doc` folder
and add it to the `.bidsignore` file to make sure it is ignored by the BIDS validator.

More info here: https://neurostars.org/t/where-in-a-bids-dataset-should-i-put-notes-about-individual-mri-acqusitions/17315/3

## Details related to access to the data

- [ ] Data user agreement

If the dataset requires a data user agreement, link to the relevant information.
Copy/paste when decided

- [x] Contact persons

Indicate the name and contact details (email and ORCID) of the person responsible for additional information.

* Mikkel C. Vinding, email: mikkel.vinding@ki.se, ORCID:  https://orcid.org/0000-0002-7954-2886
* Daniel Lundqvist, email: daniel.lundqvist@ki.se


- [ ] Practical information to access the data

If there is any special information related to access rights or
how to download the data make sure to include it.
For example, if the dataset was curated using datalad,
make sure to include the relevant section from the datalad handbook:
http://handbook.datalad.org/en/latest/basics/101-180-FAQ.html#how-can-i-help-others-get-started-with-a-shared-dataset

## Overview

- [ ] Project name (if relevant)
The Swedish National Facility for Magnetoencephalography Parkinson's Disease Dataset (NatMEG-PDD)

- [ ] Year(s) that the project ran
Data collected April 2019 - March 2020

If no `scans.tsv` is included, this could at least cover when the data acquisition
starter and ended. Local time of day is particularly relevant to subject state.

- [ ] Brief overview of the tasks in the experiment

A paragraph giving an overview of the experiment. This should include the
goals or purpose and a discussion about how the experiment tries to achieve
these goals.

- [ ] Description of the contents of the dataset

An easy thing to add is the output of the bids-validator that describes what type of
data and the number of subject one can expect to find in the dataset.

Summary: 134 - Subjects, 1 - Session

Available Tasks: Resting-state, Passive movements, Go task

Available Modalities: Magnetoencephalography (MEG)

- [ ] Independent variables

A brief discussion of condition variables (sometimes called contrasts
or independent variables) that were varied across the experiment.

- [ ] Dependent variables

A brief discussion of the response variables (sometimes called the
dependent variables) that were measured and or calculated to assess
the effects of varying the condition variables. This might also include
questionnaires administered to assess behavioral aspects of the experiment.

- [ ] Control variables

A brief discussion of the control variables --- that is what aspects
were explicitly controlled in this experiment. The control variables might
include subject pool, environmental conditions, set up, or other things
that were explicitly controlled.

- [ ] Quality assessment of the data

Provide a short summary of the quality of the data ideally with descriptive statistics if relevant
and with a link to more comprehensive description (like with MRIQC) if possible.

## Methods

### Subjects

A brief sentence about the subject pool in this experiment.

Remember that `Control` or `Patient` status should be defined in the `participants.tsv`
using a group column.

- [ ] Information about the recruitment procedure
- [ ] Subject inclusion criteria (if relevant)
- [ ] Subject exclusion criteria (if relevant)

The study includes 80 PD patients (age 44-85; 32 female) and 71 healthy controls (age 46-78; 46 female). Subjects from the patient group were recruited from the Parkinson's Outpatient Clinic, Department of Neurology, Karolinska University Hospital, Stockholm, Sweden. Recruitment of healthy controls was conducted via advertising or amongst spouses of PD patients. The criteria of inclusion for the PD group were a PD diagnosis according to the United Kingdom Parkinson's Disease Society Brain Bank Diagnostic Criteria with Hoehn and Yahr stage 1-3. Inclusion criteria for the control group were the absence of PD diagnosis, absence of any form of movement disorder, and no history of neurological diseases, psychiatric disorders, or epilepsy. Exclusion criteria for both groups were a diagnosis of major depression, dementia, history or presence of schizophrenia, bipolar disorder, epilepsy, or history of alcoholism or drug addiction according to the Diagnostic and Statistical Manual of Mental Disorders. (Vinding et.al. 2022)

### Apparatus

A summary of the equipment and environment setup for the
experiment. For example, was the experiment performed in a shielded room
with the subject seated in a fixed position.

### Initial setup

A summary of what setup was performed when a subject arrived.

### Task organization

How the tasks were organized for a session.
This is particularly important because BIDS datasets usually have task data
separated into different files.)

- [ ] Was task order counter-balanced?
- [ ] What other activities were interspersed between tasks?

- [ ] In what order were the tasks and other activities performed?

### Task details

As much detail as possible about the task and the events that were recorded.

### Additional data acquired

A brief indication of data other than the
imaging data that was acquired as part of this experiment. In addition
to data from other modalities and behavioral data, this might include
questionnaires and surveys, swabs, and clinical information. Indicate
the availability of this data.

This is especially relevant if the data are not included in a `phenotype` folder.
https://bids-specification.readthedocs.io/en/stable/03-modality-agnostic-files.html#phenotypic-and-assessment-data

### Experimental location

This should include any additional information regarding the
the geographical location and facility that cannot be included
in the relevant json files.

### Missing data

Mention something if some participants are missing some aspects of the data.
This can take the form of a processing log and/or abnormalities about the dataset.

Some examples:

- A brain lesion or defect only present in one participant
- Some experimental conditions missing on a given run for a participant because
  of some technical issue.
- Any noticeable feature of the data for certain participants
- Differences (even slight) in protocol for certain participants.

#### Clinical data and metadata
- Participant 093 had a LT foot injury and was unable to put weight on foot. Unrated for all LLE, Gait, and Balance categories on UPDRS.

#### MEG recordings and data
- Task "Passive" were not acquired for participants 020, 034, 062, 092 117, and 126.
- cHPI was not turned on during "Rest" for participant 025. Maxfilter run with tSSS but no compensation for head movement.

##### Resting-state
- Alternative/missing triggers...

##### Go task
- Alternative/missing triggers...

##### Passive movements
- Alternative/missing triggers...

#### MRI recordings and data
- MRI were not acquired for participants 019, 024, 033, 039, 057, 066, 072, 088, 091, 111, and 129 because cancellation due to COVID-19 lockdown of the MR scanner.
- MRI is missing for participant 061 due to corrupted source files.
- Participant 070 did not do MRI.

### Notes

Any additional information or pointers to information that
might be helpful to users of the dataset. Include qualitative information
related to how the data acquisition went.

