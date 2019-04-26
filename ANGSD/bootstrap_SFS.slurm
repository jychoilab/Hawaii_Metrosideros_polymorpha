#!/bin/bash
#SBATCH --cpus-per-task=20
#SBATCH --time=120:00:00
#SBATCH --mem=80GB
#SBATCH -o slurm.%j.out
#SBATCH -e slurm.%j.err

######

SFS=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/PopStats/SFS/RANDOM_SITE/Win10000_SNPdist5000/N/RandomSite.Win10000_SNPdist5000_minInd10_setMinDepth103_setMaxDepth924.saf.idx

######

cd "$SLURM_SUBMIT_DIR"

realSFS pop.saf.idx -bootstrap 100 -P number_of_cores


