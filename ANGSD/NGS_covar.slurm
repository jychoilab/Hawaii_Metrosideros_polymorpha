#!/bin/bash
#SBATCH --cpus-per-task=1
#SBATCH --time=4:00:00
#SBATCH --mem=8GB
#SBATCH -o slurm.%j.out
#SBATCH -e slurm.%j.err

module purge
module load ngstools/intel/20170228

#####

GENO=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/PCA/RANDOM_SITE/Win10000_SNPdist5000/AllSample.RFfilter_RandomSite.Win10000_SNPdist5000.geno
OUTFILE=RandomSite.Win10000_SNPdist5000.covar
IND=40
NSITES=28725

#####


cd "$SLURM_SUBMIT_DIR"

ngsCovar -probfile "$GENO" \
-outfile "$OUTFILE" \
-nind "$IND" \
-nsites "$NSITES" \
-call 0 -norm 0


