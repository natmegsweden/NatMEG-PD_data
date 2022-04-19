# Arrange MRI data and create json sidecar file
# The script is working. Outputs anonymized json sidecar files.
# TO DO: 
# * Find a way to use anonymized id instead of NatMEG id.
# * Could probably write directly to the anonymize dir with the nifti files.


RAW=/archive/20079_parkinsons_longitudinal/MRI
BIDS=/home/mikkel/PD_long/data_share/temp

while IFS=, read -r SUB DCM_DIR ID; do
echo "============ $SUB ============"
FILE="${RAW}/NatMEG_${SUB}/$DCM_DIR"
echo " *** Folder is $DCM_DIR ***"

if [ ! -d "$FILE" ]; then
	echo "$FILE does NOT exist"	
	continue
else
	echo "$FILE exists."
fi

mkdir -p $BIDS/sub-$ID/anat   
dcm2niix -i y -b o -ba y -o ${BIDS}/sub-${ID}/anat -f sub-${SUB}_T1w ${RAW}/NatMEG_${SUB}/$DCM_DIR

done < <(tail -n +2 /home/mikkel/PD_long/subj_data/alldata.csv)

#END
