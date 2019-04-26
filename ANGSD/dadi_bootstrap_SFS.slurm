#!/bin/bash
#SBATCH --cpus-per-task=20
#SBATCH --time=30:00:00
#SBATCH --mem=60GB
#SBATCH -o slurm.%j.out
#SBATCH -e slurm.%j.err

# create random site SFS for two popl

###

RANDSITE=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/RandomSite.Win10000_SNPdist5000.txt
P1_BAMLIST=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/bam.G1.list
P2_BAMLIST=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/bam.N.list
REF=/scratch/jyc387/Metrosideros_Project/REFGENOME/Izuno_etal_2016/GCA_001662345.1_Mpo_1.0_genomic.scaffold_name_change.ge10kbp.fna
OUTDIR=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/PopStats/BootStrap_SFS

# what parameter to use for ANGSD
minMapQ=30
minQ=30

#AlakaiG
P1_minInd=6; P1_setMinDepth=58; P1_setMaxDepth=523
# N
P2_minInd=10; P2_setMinDepth=103; P2_setMaxDepth=924
# G2
#minInd=3; setMinDepth=23; setMaxDepth=207

###

cd "$OUTDIR"

# create folder to hold everything
mkdir RAND_REP"${SLURM_ARRAY_TASK_ID}"; cd RAND_REP"${SLURM_ARRAY_TASK_ID}"

# create random list of sites
for i in $(seq 1 $(wc -l < "$RANDSITE")); do shuf -n 1 "$RANDSITE"; done | sort > random.list
RF=$(echo "$PWD"/random.list)

# Pop1 likelihood
angsd -P "$SLURM_CPUS_ON_NODE" -b "$P1_BAMLIST" -ref $REF -anc $REF -out POP1_random"${SLURM_ARRAY_TASK_ID}" -rf "$RF" \
-uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -trim 0 -C 50 -baq 1 \
-minMapQ "$minMapQ" -minQ "$minQ" -minInd "$P1_minInd" -setMinDepth "$P1_setMinDepth" -setMaxDepth "$P1_setMaxDepth" -doCounts 1 \
-GL 1 -doSaf 1

#realSFS -P "$SLURM_CPUS_ON_NODE" POP1_random"${SLURM_ARRAY_TASK_ID}".saf.idx > POP1_random"${SLURM_ARRAY_TASK_ID}".sfs

# Pop2 likelihood
angsd -P "$SLURM_CPUS_ON_NODE" -b "$P2_BAMLIST" -ref $REF -anc $REF -out POP2_random"${SLURM_ARRAY_TASK_ID}" -rf "$RF" \
-uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -trim 0 -C 50 -baq 1 \
-minMapQ "$minMapQ" -minQ "$minQ" -minInd "$P2_minInd" -setMinDepth "$P2_setMinDepth" -setMaxDepth "$P2_setMaxDepth" -doCounts 1 \
-GL 1 -doSaf 1

#realSFS -P "$SLURM_CPUS_ON_NODE" POP2_random"${SLURM_ARRAY_TASK_ID}".saf.idx > POP2_random"${SLURM_ARRAY_TASK_ID}".sfs

# saf.idx file
POP1=POP1_random"${SLURM_ARRAY_TASK_ID}".saf.idx
POP2=POP2_random"${SLURM_ARRAY_TASK_ID}".saf.idx

# initially need to estimate 2D-SFS between two group. May use alot of memory (>40G)
realSFS -P "$SLURM_CPUS_ON_NODE" "$POP1" "$POP2" > POP1_POP2_random"${SLURM_ARRAY_TASK_ID}".2D.sfs



