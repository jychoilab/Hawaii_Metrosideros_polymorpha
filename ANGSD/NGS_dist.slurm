#!/bin/bash
#SBATCH --cpus-per-task=20
#SBATCH --time=48:00:00
#SBATCH --mem=40GB
#SBATCH -o slurm.%j.out
#SBATCH -e slurm.%j.err

module purge
module load ngstools/intel/20170228
module load raxml/intel/8.2.10

##### param setup

INDIR=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/NGSdist
OUTNAME="AllSample"

N_ind=40
LABEL=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/LIST/sample.list


# bootstapping? YES for 1
BOOT=1
BOOTREP=1000
BOOTBLOCK=50
#####

GENO="$INDIR"/"$OUTNAME".geno.gz
MAF="$INDIR"/"$OUTNAME".mafs.gz
N_SITES=$(zcat "$MAF" | tail -n+2 | wc -l)

cd "$SLURM_SUBMIT_DIR"

if [[ $BOOT -eq 0 ]]; then
# single pairwise matrix
ngsDist -verbose 1 -geno "$GENO" -probs -n_ind "$N_ind" -n_sites $N_SITES -labels "$LABEL" -o "$OUTNAME".distance.txt -n_threads "$SLURM_CPUS_ON_NODE"

else
# bootstrapping
ngsDist -verbose 1 -geno "$GENO" -probs -n_ind "$N_ind" -n_sites $N_SITES -labels "$LABEL" -o "$OUTNAME".distance.txt -n_threads "$SLURM_CPUS_ON_NODE" --n_boot_rep "$BOOTREP" --boot_block_size "$BOOTBLOCK"

# bootstrap trees
/home/jyc387/PROGRAMS_AND_SCRIPTS/PROGRAMS/fastme-2.1.5/binaries/fastme-2.1.5-linux64 -T "$SLURM_CPUS_ON_NODE" -D "$(echo "$BOOTREP +1" | bc)" -i "$OUTNAME".distance.txt -o "$OUTNAME".DEFAULT.tree
head -n 1 "$OUTNAME".DEFAULT.tree > "$OUTNAME".DEFAULT.main.tree
tail -n +2 "$OUTNAME".DEFAULT.tree | awk 'NF' > "$OUTNAME".DEFAULT.boot.tree
raxmlHPC -f b -t "$OUTNAME".DEFAULT.main.tree -z "$OUTNAME".DEFAULT.boot.tree -m GTRCAT -n "$OUTNAME".DEFAULT

fi

# build tree
#/home/jyc387/PROGRAMS_AND_SCRIPTS/PROGRAMS/fastme-2.1.5/binaries/fastme-2.1.5-linux64 -D 1 -i "$OUTNAME".distance.txt -o "$OUTNAME".tree -m b -n b
#/home/jyc387/PROGRAMS_AND_SCRIPTS/PROGRAMS/fastme-2.1.5/binaries/fastme-2.1.5-linux64 -D 1 -i "$OUTNAME".distance.txt -o "$OUTNAME".DEFAULT.tree



