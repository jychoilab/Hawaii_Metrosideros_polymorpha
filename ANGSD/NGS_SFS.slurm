#!/bin/bash
#SBATCH --cpus-per-task=20
#SBATCH --time=120:00:00
#SBATCH --mem=80GB
#SBATCH -o slurm.%j.out
#SBATCH -e slurm.%j.err


### set up parameters

BAMLIST=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/bam.AllN.list
# refgenome
REF=/scratch/jyc387/Metrosideros_Project/REFGENOME/Izuno_etal_2016/GCA_001662345.1_Mpo_1.0_genomic.scaffold_name_change.ge10kbp.fna
OUTNAME="AllN"

# specify a region? Used to pull out random regions. $RFLIST is in case there were too many scaffolds so divide it up and run with parallel
#RF=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/PCA/RandomSite.Win10000_SNPdist5000.txt
RFLIST=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/LIST/CHRLIST

# what parameter to use for ANGSD
minMapQ=30
minQ=30
minInd=15; setMinDepth=135; setMaxDepth=1218

###

cd "$SLURM_SUBMIT_DIR"

# NOTE that if $REF is used as -anc option then its simply using reference genome to determine high vs low frequency variants. Which is not suitable for stats such as Fay Wu H etc but does its job to calculate SFS
if [[ -z "$RFLIST" ]]; then

	if [[ -z "$RF" ]]; then

		angsd -P "$SLURM_CPUS_ON_NODE" -b "$BAMLIST" -ref $REF -anc $REF -out "$OUTNAME"_minInd"$minInd"_setMinDepth"$setMinDepth"_setMaxDepth"$setMaxDepth" \
			-uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -trim 0 -C 50 -baq 1 \
			-minMapQ "$minMapQ" -minQ "$minQ" -minInd "$minInd" -setMinDepth "$setMinDepth" -setMaxDepth "$setMaxDepth" -doCounts 1 \
			-GL 1 -doSaf 1
	else
		OUTNAME=$(echo "$(basename "$RF")" | perl -pe 's/.txt//')
		angsd -P "$SLURM_CPUS_ON_NODE" -b "$BAMLIST" -ref $REF -anc $REF -out "$OUTNAME"_minInd"$minInd"_setMinDepth"$setMinDepth"_setMaxDepth"$setMaxDepth" -rf "$RF" \
			-uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -trim 0 -C 50 -baq 1 \
			-minMapQ "$minMapQ" -minQ "$minQ" -minInd "$minInd" -setMinDepth "$setMinDepth" -setMaxDepth "$setMaxDepth" -doCounts 1 \
			-GL 1 -doSaf 1

	fi

else

	ls "$RFLIST"/* | parallel -j "$SLURM_CPUS_ON_NODE" "angsd -rf {}  -b "$BAMLIST" -ref $REF -anc $REF -out "$OUTNAME".{/} -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -trim 0 -C 50 -baq 1 -minMapQ "$minMapQ" -minQ "$minQ" -minInd "$minInd" -setMinDepth "$setMinDepth" -setMaxDepth "$setMaxDepth" -doCounts 1 -GL 1 -doSaf 1"

fi


if [[ -z "$RFLIST" ]]; then

	# estimate SFS
	realSFS -P "$SLURM_CPUS_ON_NODE" "$OUTNAME"_minInd"$minInd"_setMinDepth"$setMinDepth"_setMaxDepth"$setMaxDepth".saf.idx > "$OUTNAME"_minInd"$minInd"_setMinDepth"$setMinDepth"_setMaxDepth"$setMaxDepth".sfs

fi


