#!/bin/bash
#SBATCH --cpus-per-task=20
#SBATCH --time=100:00:00
#SBATCH --mem=80GB
#SBATCH -o slurm.%j.out
#SBATCH -e slurm.%j.err

#module purge
#module load ngstools/intel/20170228

### set up parameters

BAMLIST=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/bam.AllG.list
REF=/scratch/jyc387/Metrosideros_Project/REFGENOME/Izuno_etal_2016/GCA_001662345.1_Mpo_1.0_genomic.scaffold_name_change.ge10kbp.fna
OUTNAME="AllG"
# .sfs file
SFS_PRIOR=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/PopStats/SFS/AllG/AllG.merged.sfs
minMapQ=30
minQ=30

#AlakaiG
#minInd=6; setMinDepth=58; setMaxDepth=523
# N
#minInd=10; setMinDepth=103; setMaxDepth=924
# G2
#minInd=3; setMinDepth=23; setMaxDepth=207
# All G
minInd=15; setMinDepth=128; setMaxDepth=1158
# All N
#minInd=15; setMinDepth=135; setMaxDepth=1218


###

cd "$SLURM_SUBMIT_DIR"

# NOTE that if $REF is used as -anc option then its simply using reference genome to determine high vs low frequency variants. Which is not suitable for stats such as Fay Wu H etc but does its job to calculate SFS

angsd -P "$SLURM_CPUS_ON_NODE" -b "$BAMLIST" -ref $REF -anc $REF -out "$OUTNAME"_minInd"$minInd"_setMinDepth"$setMinDepth"_setMaxDepth"$setMaxDepth" \
        -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -trim 0 -C 50 -baq 1 \
        -minMapQ "$minMapQ" -minQ "$minQ" -minInd "$minInd" -setMinDepth "$setMinDepth" -setMaxDepth "$setMaxDepth" -doCounts 1 -GL 1 -doSaf 1 \
	-doThetas 1 -pest "$SFS_PRIOR"


## in newest ANGSD ver>0.9.1.7 seems like below method is not used anymore
#thetaStat make_bed "$OUTNAME"_minInd"$minInd"_setMinDepth"$setMinDepth"_setMaxDepth"$setMaxDepth".thetas.gz


