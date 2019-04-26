#!/bin/bash
#SBATCH --cpus-per-task=20
#SBATCH --time=120:00:00
#SBATCH --mem=80GB
#SBATCH -o slurm.%j.out
#SBATCH -e slurm.%j.err

#module purge
#module load ngstools/intel/20170228

### set up parameters

BAMLIST=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/bam.list
REF=/scratch/jyc387/Metrosideros_Project/REFGENOME/Izuno_etal_2016/GCA_001662345.1_Mpo_1.0_genomic.scaffold_name_change.ge10kbp.fna
OUTNAME="AllSample"

#$RFLIST is in case there were too many scaffolds so divide it up and run with parallel
RFLIST=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/LIST/CHRLIST

# what parameter to use for ANGSD
minMapQ=30
minQ=30

# 75% of individuals
minInd=30

# min = 1/3 and max = X3 of mean depth
setMinDepth=270
setMaxDepth=2434

###

cd "$SLURM_SUBMIT_DIR"

if [[ -z "$RFLIST" ]]; then

	angsd -P "$SLURM_CPUS_ON_NODE" -b "$BAMLIST" -ref $REF -out "$OUTNAME" \
		-uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -trim 0 -C 50 -baq 1 \
		-minMapQ "$minMapQ" -minQ "$minQ" -minInd "$minInd" -setMinDepth "$setMinDepth" -setMaxDepth "$setMaxDepth" -doCounts 1 \
		-GL 1 -doMajorMinor 1 -doMaf 1 -skipTriallelic 1 \
		-SNP_pval 1e-6 \
		-doGeno 8 -doPost 1

else

	ls "$RFLIST"/* | parallel -j "$SLURM_CPUS_ON_NODE" "angsd -rf {}  -b "$BAMLIST" -ref "$REF" -out "$OUTNAME".{/} -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -trim 0 -C 50 -baq 1 -minMapQ "$minMapQ" -minQ "$minQ" -minInd "$minInd" -setMinDepth "$setMinDepth" -setMaxDepth "$setMaxDepth" -doCounts 1 -GL 1 -doMajorMinor 1 -doMaf 1 -skipTriallelic 1 -SNP_pval 1e-6 -doGeno 8 -doPost 1"

fi


