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
#BAMLIST=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/bam.N.list
REF=/scratch/jyc387/Metrosideros_Project/REFGENOME/Izuno_etal_2016/GCA_001662345.1_Mpo_1.0_genomic.scaffold_name_change.ge10kbp.fna
OUTNAME="N"

# specify a region? Used to pull out random regions. $RFLIST is in case there were too many scaffolds so divide it up and run with parallel
RF=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/PCA/RandomSite.Win10000_SNPdist5000.txt
#RFLIST=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/LIST/CHRLIST

# what parameter to use for ANGSD
minMapQ=30
minQ=30

# 75% of individuals
#minInd=30

# min = 1/3 and max = X3 of mean depth
#setMinDepth=270
#setMaxDepth=2434

#AlakaiG
#minInd=6; setMinDepth=58; setMaxDepth=523
# N
minInd=10; setMinDepth=103; setMaxDepth=924
# G2
##minInd=3; setMinDepth=23; setMaxDepth=207


###

cd "$SLURM_SUBMIT_DIR"

# Look at the PDF from the QC analysis to determine the minQ, minInd, setMinDepth and setMaxDepth cutoffs
# minInd was determined as half the total number of individuals
# setMinDepth and setMaxDepth was determined and looking at the global depth distribution. 

if [[ -z "$RFLIST" ]]; then

	if [[ -z "$RF" ]]; then

		angsd -P "$SLURM_CPUS_ON_NODE" -b "$BAMLIST" -ref "$REF" -out "$OUTNAME" \
			-uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -trim 0 -C 50 -baq 1 \
			-minMapQ "$minMapQ" -minQ "$minQ" -minInd "$minInd" -setMinDepth "$setMinDepth" -setMaxDepth "$setMaxDepth" -doCounts 1 \
			-GL 1 -doMajorMinor 4 -doMaf 1 -skipTriallelic 1 \
			-doGlf 2 -SNP_pval 1e-6

	else
		OUTNAME="$(printf "${OUTNAME}.RFfilter_$(echo "$(basename "$RF")" | perl -pe 's/.txt//')")"

		angsd -P "$SLURM_CPUS_ON_NODE" -b "$BAMLIST" -ref "$REF" -out "$OUTNAME" -rf "$RF" \
			-uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -trim 0 -C 50 -baq 1 \
			-minMapQ "$minMapQ" -minQ "$minQ" -minInd "$minInd" -setMinDepth "$setMinDepth" -setMaxDepth "$setMaxDepth" -doCounts 1 \
			-GL 1 -doMajorMinor 4 -doMaf 1 -skipTriallelic 1 \
			-doGlf 2 -SNP_pval 1e-6

	fi

else

	ls "$RFLIST"/* | parallel -j "$SLURM_CPUS_ON_NODE" "angsd -rf {} -b "$BAMLIST" -ref "$REF" -out "$OUTNAME".{/} -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -trim 0 -C 50 -baq 1 -minMapQ "$minMapQ" -minQ "$minQ" -minInd "$minInd" -setMinDepth "$setMinDepth" -setMaxDepth "$setMaxDepth" -doCounts 1 -GL 1 -doMajorMinor 4 -doMaf 1 -skipTriallelic 1 -doGlf 2 -SNP_pval 1e-6 "

fi


