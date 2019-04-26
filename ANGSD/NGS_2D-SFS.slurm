#!/bin/bash
#SBATCH --cpus-per-task=20
#SBATCH --time=6:00:00
#SBATCH --mem=80GB
#SBATCH -o slurm.%j.out
#SBATCH -e slurm.%j.err

#module purge
#module load ngstools/intel/20170228

###

# saf.idx file
POP1=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/PopStats/SFS/RANDOM_SITE/Win10000_SNPdist5000/G2/RandomSite.Win10000_SNPdist5000_minInd3_setMinDepth23_setMaxDepth207.saf.idx
POP2=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/PopStats/SFS/RANDOM_SITE/Win10000_SNPdist5000/N/RandomSite.Win10000_SNPdist5000_minInd10_setMinDepth103_setMaxDepth924.saf.idx

# outname
OUTNAME="G2-N"

###

cd "$SLURM_SUBMIT_DIR"

# initially need to estimate 2D-SFS between two group. May use alot of memory (>40G)
realSFS -P 20 "$POP1" "$POP2" > "$OUTNAME".2D.sfs


