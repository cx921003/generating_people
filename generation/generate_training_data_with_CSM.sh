#!/bin/bash
set -e  # Exit on error.

data_fp=/home/xu/workspace/generating_people/generation/data/pose/extracted/test/


#if [ -z ${1+x} ]; then
#   echo Please specify the number of people! >&2; exit 1
#fi
#npeople=$1
#re='^[0-9]+$'
#if ! [[ $1 =~ $re ]] ; then
#    echo "Error: specify a number" >&2; exit 1
#fi

if [ -z ${2+x} ]; then
    out_fp=/home/xu/data/CSM_samples
else
    out_fp=$2
fi
if [ -e ${out_fp} ]; then
    echo "Output folder exists: ${out_fp}. Please pick a non-existing folder." >&2
    exit 1
fi

# Check environment.
if [ ! -d experiments/states/CSM_pretrained ]; then
    echo "State folder for the latent sketch module not found at " >&2
    echo "'experiments/states/LSM'. Either run the training (./run.py trainval experiments/config/LSM) " >&2
    echo "or download a pretrained model from http://gp.is.tuebingen.mpg.de." >&2
    exit 1
fi



echo Generating $1 people...
echo Sampling sketches...
./run.py test experiments/config/CSM_pretrained --override_dset_suffix tmp_for_data_generation --out_fp ${out_fp}
echo Done.

#
#echo Cleaning up...
#rm -rf tmp
#rm -rf data/people/tmp
#echo Done
