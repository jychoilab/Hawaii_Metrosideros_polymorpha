#!/bin/bash
#SBATCH --cpus-per-task=20
#SBATCH --time=48:00:00
#SBATCH --mem=60GB
#SBATCH -o slurm.%j.out
#SBATCH -e slurm.%j.err

module purge
module load ngsadmix/intel/32

### set up parameters

# input output
BEAGLE_LIK=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/NGSadmix/RANDOM_SITE/Win10000_SNPdist5000/AllSample.RFfilter_RandomSite.Win10000_SNPdist5000.beagle.gz
OUTDIR=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/NGSadmix/lnL/Win10000_SNPdist5000

# maximum K value to test
maxK=7
# number of reps per K
REPS=50

###

for i in $(seq 2 "$maxK"); do

        cd "$OUTDIR"
        mkdir K"$i"
        cd K"$i"

        for j in $(seq 1 "$REPS"); do
                NGSadmix -likes "$BEAGLE_LIK" -K "$i" -P "$SLURM_CPUS_ON_NODE" -o admix_out_K"$i"_rep"$j" -minMaf 0.05
        done

done
