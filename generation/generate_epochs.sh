#!/bin/bash
set -e  # Exit on error.

data_fp=/home/xu/workspace/generating_people/generation/data/pose/extracted/test
exp_name=PM
if [ -z ${1+x} ]; then
   echo Please specify the number of people! >&2; exit 1
fi
npeople=$1
re='^[0-9]+$'
if ! [[ $1 =~ $re ]] ; then
    echo "Error: specify a number" >&2; exit 1
fi

if [ -z ${2+x} ]; then
    out_fp=generated
else
    out_fp=$2
fi
if [ -e ${out_fp} ]; then
    echo "Output folder exists: ${out_fp}. Please pick a non-existing folder." >&2
    exit 1
fi

# Check environment.
if [ -e tmp ]; then
    echo "The directory 'tmp' exists, maybe from an incomplete previous run?" >&2
    echo "If so, please delete it and rerun so that it can be used cleanly." >&2
    exit 1
fi
if [ -e data/people/tmp ]; then
    echo "The directory 'data/people/tmp' exists, maybe from an incomplete previous run?" >&2
    echo "If so, please delete it and rerun so that it can be used cleanly." >&2
    exit 1
fi


echo Preparing for portray module...
mkdir tmp/portray_dset -p

for sample_idx in $(seq 0 $((${npeople}-1))); do
    fullid=$(printf "%04d" ${sample_idx})
    # Simulate full dataset.
    cp ${data_fp}/${fullid}_bodysegments.png tmp/portray_dset/${fullid}_bodysegments:png.png
    cp ${data_fp}/${fullid}_bodysegments_vis.png tmp/portray_dset/${fullid}_bodysegments_vis:png.png
    cp ${data_fp}/${fullid}_image:png.png tmp/portray_dset/${fullid}_image:png.png
    cp ${data_fp}/${fullid}_labels:png.png tmp/portray_dset/${fullid}_labels:png.png
    cp ${data_fp}/${fullid}_label_vis:png.png tmp/portray_dset/${fullid}_label_vis:png.png
    echo ${fullid}_sample.png > tmp/portray_dset/${fullid}_original_filename.txt
done

echo Creating archive...
mkdir -p data/people/tmp
mkdir -p ${out_fp}/images
tfrpack tmp/portray_dset --out_fp data/people/tmp/test
echo Done.

echo Creating images...

filename=experiments/states/${exp_name}/checkpoint


sed 1d ${filename} | while read -r line
do
    name=${line#*'"'}; name=${name%'"'*}
    if [[ $name =~ */* ]]; then
        name=experiments/states/${exp_name}/${name}
    fi
    step=${name##*/}
    step=$(printf "%07d" ${step:6})

    ./run.py test experiments/config/${exp_name} --override_dset_suffix tmp --out_fp ${out_fp} --checkpoint ${name}.meta

    for sample_idx in $(seq 0 $((${npeople}-1))); do
        fullid=$(printf "%04d" ${sample_idx})
        mv ${out_fp}/images/${fullid}_sample_outputs.png ${out_fp}/images/${step}_${fullid}outputs.png
    done

done

echo Done.

echo Cleaning up...
rm -rf tmp
rm -rf data/people/tmp
echo Done

echo Copying Ground Truth...
for sample_idx in $(seq 0 $((${npeople}-1))); do
    fullid=$(printf "%04d" ${sample_idx})
    # Simulate full dataset.
    cp ${data_fp}/${fullid}_image:png.png ${out_fp}/images/GToutput_${fullid}outputs.png
    cp ${data_fp}/${fullid}_label_vis:png.png ${out_fp}/images/GTcloth_${fullid}outputs.png
    cp ${data_fp}/${fullid}_bodysegments_vis.png ${out_fp}/images/GTbody_${fullid}outputs.png

    rm ${out_fp}/images/${fullid}_sample_inputs.png
    rm ${out_fp}/images/${fullid}_sample_targets.png

done
echo Done.

echo Generating HTML
rm ${out_fp}/index.html
./generate_index.py ${out_fp}/images
echo Done.

# TODO display the ground-truth also
