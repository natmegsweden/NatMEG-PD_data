cd /home/mikkel/PD_long/data_share/textfiles
dest='/home/mikkel/PD_long/data_share/BIDS_data'

# Copy
cp CHANGES.txt $dest
cp README.md $dest
cp participants.json $dest
cp dataset_description.json $dest

cp ./derivatives/warpimg/dataset_description.json $dest/derivatives/warpimg/dataset_description.json
cp ./derivatives/warpimg/participants.tsv $dest/derivatives/warpimg/participants.tsv

echo 'done'
