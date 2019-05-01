#!/bin/bash
#SBATCH --cpus-per-task=20
#SBATCH --time=12:00:00
#SBATCH --mem=60GB
#SBATCH -o slurm.%j.out
#SBATCH -e slurm.%j.err

####

# input VCF
VCF=COREPOP.combined.ALLCHR.SNP.FILTERED.PASS.MaxMissing0.8.Npop.recode.vcf

# scaffold list (two column list where col1 is scaffold name and col2 is size of scaffold)
SCAFFOLD=/scratch/jyc387/Metrosideros_Project/ANALYSIS/SWEEPS/scaffold.list

# grid corresponds to number of windows to calculate OmegaPlus stats. When you have multiple scaffolds then number of grids should correpsond to the physical bps a grid should contain. $GRID_BP represents the physical grid size in bp and the script will divide that by the chr/scaffold size to determine the total number of grids that would be needed.
GRID_BP=5000
# min and max window the grid looks at to determine the omegaplus stat. Seems like maxwin matters alot so make it large
MINWIN=5000
MAXWIN=500000

OUTNAME="bas"

#program
OMEGAPLUS=/home/jyc387/PROGRAMS_AND_SCRIPTS/PROGRAMS/omegaplus/OmegaPlus-M

####

cd "$SLURM_SUBMIT_DIR"

while read -r LINE; do

	C=$(awk '{print $1}' <<< "$LINE")
	S=$(awk '{print $2}' <<< "$LINE")
	GRID=$(echo "$S / $GRID_BP" | bc -l | perl -pe 's/\..+//')

	vcftools --vcf "$VCF" --chr "$C" --recode --out "$C"

	"$OMEGAPLUS" -name "$OUTNAME"."$C".grid"$GRID".minwin"$MINWIN".maxwin"$MAXWIN".NoSingleton -input "$C".recode.vcf -grid "$GRID" -minwin "$MINWIN" -maxwin "$MAXWIN" -no-singletons -seed "$RANDOM" -threads 20
	
	rm "$C"*

done < <(cat "$SCAFFOLD")


