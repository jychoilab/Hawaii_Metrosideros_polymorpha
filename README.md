# Scripts and commands used for Hawaiian Metrosideros polymorpha project by Choi et al.

## Start from FASTQ to end with with VCF
### Use commands outlined in Choi et al. 2019 Plos Genet study
https://github.com/cjy8709/Choi_etal_O.glaberrima_PopGenome/blob/master/FromFASTQ_to_VCF.sh

## Slurm scripts associated with ANGSD analysis
### Misc. commands
#### Select random SNP positions
ANGSD/random_site_select.slurm

### Admxiture analysis
#### Calculate GL
ANGSD/NGS_GL_NGSadmix.slurm

#### NGSadmix
ANGSD/NGS_admix.slurm

### Phylogeny and distance
#### Calculate Genotype Posterior Probability
ANGSD/NGS_GPP_DIST.slurm

#### Calculate genetic distance and create NJ tree
ANGSD/NGS_dist.slurm

### PCA
#### Calculate Genotype Posterior Probability
ANGSD/NGS_GPP_PCA.slurm

#### PCA with ANGSD
ANGSD/NGS_covar.slurm

### SFS estimation for dadi
#### 1D SFS for single popl
ANGSD/NGS_SFS.slurm

#### 2D SFS for two popl
ANGSD/NGS_2D-SFS.slurm

#### bootstrap SFS
ANGSD/bootstrap_SFS.slurm


## Sweep analysis
### Commands and scripts used for Omegaplus, H12, and Hscan statsitics calculation 
SWEEPS/SWEEP_commands.txt
