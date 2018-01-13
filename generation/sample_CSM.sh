#!/bin/bash
set -e  # Exit on error.

data_fp=/home/xu/workspace/generating_people/generation/data/pose/extracted/test
exp_name=CSM_pretrained
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
if [ -e ./data/people/tmp ]; then
    echo "The directory 'data/people/tmp' exists, maybe from an incomplete previous run?" >&2
    echo "If so, please delete it and rerun so that it can be used cleanly." >&2
    exit 1
fi
if [ ! -d ./experiments/states/${exp_name} ]; then
    echo "State folder for the latent sketch module not found at " >&2
    echo "'experiments/states/LSM'. Either run the training (./run.py trainval experiments/config/LSM) " >&2
    echo "or download a pretrained model from http://gp.is.tuebingen.mpg.de." >&2
    exit 1
fi

echo Generating $1 people...
echo Sampling sketches...
./run.py sample experiments/config/${exp_name} --out_fp ${out_fp} --n_samples ${npeople}
echo Done.


echo Cleaning up...
rm -rf tmp
rm -rf ../data/people/tmp
echo Done

echo Copying Ground Truth...
for sample_idx in $(seq 0 $((${npeople}-1))); do
    fullid=$(printf "%04d" ${sample_idx})
    # Simulate full dataset.
    mv ${out_fp}/images/${sample_idx}_outputs.png ${out_fp}/images/${fullid}_outputs.png
    mv ${out_fp}/images/${sample_idx}_conditioning.png ${out_fp}/images/${fullid}_inputs.png

    cp ${data_fp}/${fullid}_image:png.png ${out_fp}/images/${fullid}_image.png
    cp ${data_fp}/${fullid}_label_vis:png.png ${out_fp}/images/${fullid}_targets.png
done
echo Done.

echo Generating HTML
rm ${out_fp}/index.html
./generate_index.py ${out_fp}/images
echo Done.

# TODO display the groundtruth also
