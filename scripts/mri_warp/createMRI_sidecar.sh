# Arrange MRI data and create json sidecar file
# * Find a way to use anonymized id instead of NatMEG id.



RAW=/archive/20079_parkinsons_longitudinal/MRI
BIDS=/home/mikkel/PD_long/data_share/temp

#while IFS=, read -r SUB DCM_DIR; do

SUB="0522"
DCM_DIR="00000002"

echo "============ $SUB ============"
FILE="${RAW}/NatMEG_${SUB}/$DCM_DIR"
echo "*** Folder is $DCM_DIR ***"



if [ !-d "$FILE" ]; then
	echo "$FILE exists."
else
	echo "$FILE does NOT exist"	
	continue    
fi

mkdir -p $BIDS/sub-$SUB/anat   
dcm2niix -i y -b y -ba y -o ${BIDS}/sub-${SUB}/anat -f sub-${SUB}_T1w ${RAW}/NatMEG_${SUB}/$DCM_DIR

#done < <(tail -n +2 /home/mikkel/PD_long/subj_data/alldata.csv)





#done < <(tail -n +2 /home/mikkel/PD_long/subj_data/subj_names.csv)


