#!/bin/bash
set -e  # Exit on error.

nsample=100

out_fp=$1
expA=PM
expB=PM_pretrained
expC=CycleGAN

if [ -e ${out_fp} ]; then
    echo "Output folder exists: ${out_fp}. Please pick a non-existing folder." >&2
    exit 1
fi




mkdir ${out_fp}/images -p
for sample_idx in $(seq 0 $((${nsample}-1))); do
    fullid=$(printf "%04d" ${sample_idx})
    # Simulate full dataset.
    cp results/samples/${expA}/images/${fullid}_outputs.png ${out_fp}/images/${fullid}_outputsA.png
    cp results/samples/${expB}/images/${fullid}_outputs.png ${out_fp}/images/${fullid}_outputsB.png
    cp results/samples/${expC}/images/${fullid}_outputs.png ${out_fp}/images/${fullid}_outputsC.png
    cp results/samples/${expA}/images/${fullid}_inputs.png ${out_fp}/images/${fullid}_inputs.png
    cp results/samples/${expA}/images/${fullid}_targets.png ${out_fp}/images/${fullid}_targets.png



    if [  -f results/samples/${expA}/images/${fullid}_image.png ]; then
        cp results/samples/${expA}/images/${fullid}_image.png ${out_fp}/images/${fullid}_image.png
    fi
done

echo Generating HTML...
./generate_index.py ${out_fp}/images
echo Done.

