cd /home/mikkel/PD_long/data_share/textfiles
dest='/home/mikkel/PD_long/data_share/BIDS_data'

# Copy
cp CHANGES $dest
cp README $dest
cp participants.json $dest
cp dataset_description.json $dest

cp ./derivatives/warpimg/dataset_description.json $dest/derivatives/warpimg/dataset_description.json
cp ./derivatives/warpimg/participants.tsv $dest/derivatives/warpimg/participants.tsv
cp ./derivatives/warpimg/README $dest/derivatives/warpimg/README

echo 'done'
