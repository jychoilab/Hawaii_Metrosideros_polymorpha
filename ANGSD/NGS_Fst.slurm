#!/bin/bash
#SBATCH --cpus-per-task=20
#SBATCH --time=6:00:00
#SBATCH --mem=80GB
#SBATCH -o slurm.%j.out
#SBATCH -e slurm.%j.err

module purge
module load ngstools/intel/20170228

########

POP1=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/PopStats/SFS/AlakaiG_minInd5_setMinDepth50_setMaxDepth455.saf.idx
POP2=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/PopStats/SFS/N_minInd6_setMinDepth70_setMaxDepth634.saf.idx
TWO_D_SFS=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/PopStats/2DSFS/AlakaiG-N.2D.sfs
OUTNAME=AlakaiG-N

########

cd "$SLURM_SUBMIT_DIR"

realSFS fst index "$POP1" "$POP2" -sfs "$TWO_D_SFS" -fstout "$OUTNAME" -P 20

realSFS fst stats2 "$OUTNAME".fst.idx -win 50000 -step 10000 > "$OUTNAME".fst.txt

