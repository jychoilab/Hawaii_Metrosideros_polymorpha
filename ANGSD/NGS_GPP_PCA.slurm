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

# specify a region? Used to pull out random regions. $RFLIST is in case there were too many scaffolds so divide it up and run with parallel
RF=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/PCA/RandomSite.Win10000_SNPdist5000.txt
#RFLIST=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/LIST/CHRLIST

# what parameter to use for ANGSD
minMapQ=30
minQ=30

# 75% of individuals
minInd=30

# min = 1/3 and max = X3 of mean depth
setMinDepth=270
setMaxDepth=2434

# the sliding window size. only important for ngsCovar and not used for ngsDist
#WINSIZE=50000
#MINSIZE=25000

# total number of individuals. For GetSubGeno program
Num_Ind=40

###

cd "$SLURM_SUBMIT_DIR"

if [[ -z "$RFLIST" ]]; then


	if [[ -z "$RF" ]]; then

		angsd -P "$SLURM_CPUS_ON_NODE" -b "$BAMLIST" -ref $REF -out "$OUTNAME" \
			-uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -trim 0 -C 50 -baq 1 \
			-minMapQ "$minMapQ" -minQ "$minQ" -minInd "$minInd" -setMinDepth "$setMinDepth" -setMaxDepth "$setMaxDepth" -doCounts 1 \
			-GL 1 -doMajorMinor 1 -doMaf 1 -skipTriallelic 1 \
			-SNP_pval 1e-6\
			-doGeno 32 -doPost 1

	else
		OUTNAME="$(printf "${OUTNAME}.RFfilter_$(echo "$(basename "$RF")" | perl -pe 's/.txt//')")"
		angsd -P "$SLURM_CPUS_ON_NODE" -b "$BAMLIST" -ref $REF -out "$OUTNAME" -rf "$RF" \
			-uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -trim 0 -C 50 -baq 1 \
			-minMapQ "$minMapQ" -minQ "$minQ" -minInd "$minInd" -setMinDepth "$setMinDepth" -setMaxDepth "$setMaxDepth" -doCounts 1 \
			-GL 1 -doMajorMinor 1 -doMaf 1 -skipTriallelic 1 \
			-SNP_pval 1e-6\
			-doGeno 32 -doPost 1

	fi

else

	ls "$RFLIST"/* | parallel -j "$SLURM_CPUS_ON_NODE" "angsd -rf {}  -b "$BAMLIST" -ref "$REF" -out "$OUTNAME".{/} -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -trim 0 -C 50 -baq 1 -minMapQ "$minMapQ" -minQ "$minQ" -minInd "$minInd" -setMinDepth "$setMinDepth" -setMaxDepth "$setMaxDepth" -doCounts 1 -GL 1 -doMajorMinor 1 -doMaf 1 -skipTriallelic 1 -SNP_pval 1e-6 -doGeno 32 -doPost 1"

fi


## randomly select sites
#gunzip "$OUTNAME".geno.gz
#bash /home/jyc387/PROGRAMS_AND_SCRIPTS/PROJECTS/Huang_etal_reanalysis/random_site_select.sh "$OUTNAME".mafs.gz "$WINSIZE" "$MINSIZE" > pos_file.win"$WINSIZE"_min"$MINSIZE".txt


#sed -i '/^$/d' pos_file.win"$WINSIZE"_min"$MINSIZE".txt
#N_SITES=$(zcat "$OUTNAME".mafs.gz | tail -n+2 | wc -l)
#GetSubGeno -infile "$OUTNAME".geno -posfile pos_file.win"$WINSIZE"_min"$MINSIZE".txt -nind "$Num_Ind" -nsites "$N_SITES" -len "$(wc -l < pos_file.win"$WINSIZE"_min"$MINSIZE".txt)" -outfile "$OUTNAME".win"$WINSIZE"_min"$MINSIZE".random.geno -verbose 0

#gzip "$OUTNAME".geno


