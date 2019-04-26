#!/bin/bash
#SBATCH --cpus-per-task=1
#SBATCH --time=48:00:00
#SBATCH --mem=4GB
#SBATCH -o slurm.%j.out
#SBATCH -e slurm.%j.err

cd "$SLURM_SUBMIT_DIR"

# Select random site in a window. Basically purpose is to select SNPs that are potentiall unlinked with each other. Slides through a user defined window size and selects random SNP, but then also makes sure between the SNPs are distanced at a user defined distance.
# Used for working with beagle file generated from ANGSD -glf 2 option
# or can be used for .geno.gz files as well
# can be used to generate position file that can used by GetSubGeno to extract out the position in binary format geno file (in this case use .mafs.gz file)
# MUST BE gzipped

### MUST DO!!!!!!!!!! ###
# divide the chromosome lists into seperate files and then run as an array job 
# split -l 3 /scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/LIST/RefChr.list
# i=0; for f in $(ls | grep "^x"); do mv "$f" "$i"; i=$((i+1));done

###### parameter setup

# infile has to be gz BEAGLE or GENO file
INFILE=/scratch/jyc387/Metrosideros_Project/ANALYSIS/ANGSD/PCA/AllSample.mafs.gz
WINDOWSIZE=10000
SNPDISTANCE=5000
CHRLIST="${SLURM_ARRAY_TASK_ID}"

######

########### SCRIPT STARTS HERE ############

while read -r CHRNAME; do

	FILENAME="${INFILE##*/}"
	FILENAME="${FILENAME%.*}" # name of file excluding .gz
	TYPE=$(echo ${FILENAME##*.})

	# starting window coords
	WINDOWSTART=0
	# end coordinate of the window
	WINDOWEND=$(echo "$WINDOWSTART +$WINDOWSIZE" | bc)

	# is file a beagle or geno?
	if [[ "$TYPE" == "beagle" ]]; then
		RAW_COORD=$(zgrep -w "$CHRNAME" "$INFILE" | awk '{print $1}' | perl -pe 's/(.+)_/\1\t/')
	elif [[ "$TYPE" == "mafs" ]]; then
		RAW_COORD=$(zgrep -w "$CHRNAME" "$INFILE" | awk '{printf "%s\t%s\n", $1,$2}')
	else
		RAW_COORD=$(zgrep -w "$CHRNAME" "$INFILE" | awk '{printf "%s\t%s\n", $1,$2}')
	fi

	CHRS=$(awk '{print $1}' <<< "$RAW_COORD" | sort -k1,1 -k2,2n | uniq)

	# tmp file to hold tmp variables
	if [[ -f tmp."$CHRNAME".txt ]]; then rm tmp."$CHRNAME".txt; fi
	if [[ -f CHR."$CHRNAME".Win"$WINDOWSIZE"_SNPdist"$SNPDISTANCE".txt ]]; then rm CHR."$CHRNAME".Win"$WINDOWSIZE"_SNPdist"$SNPDISTANCE".txt; fi


	while read -r CHR_SINGLE; do # loop by chromosome
		WINDOWSTART=0
		WINDOWEND=$(echo "$WINDOWSTART +$WINDOWSIZE" | bc)
		while read -r LINE; do
			CHR=$(awk '{print $1}' <<< "$LINE")
			POS=$(awk '{print $2}' <<< "$LINE")

			# if coordinate of current SNP is within window print it out to temp file
			if [[ "$POS" -ge "$WINDOWSTART" ]] && [[ "$POS" -le "$WINDOWEND" ]]; then
				echo "$POS" >> tmp."$CHRNAME".txt

			# if coordinate of current SNP is less then $windowstart and $windowend, which can happen because current coordinate can be smaller then both $WINDOWSTART and $WINDOWEND depending on what value $(echo "$RANDOM_COORD +$SNPDISTANCE"| bc) ended up to be. If current SNP position is smaller then both start and end then skip till it reaches SNP position within the window
			elif [[ "$POS" -lt "$WINDOWSTART" ]] && [[ "$POS" -lt "$WINDOWEND" ]] && [[ ! -f tmp."$CHRNAME".txt ]]; then
				continue

			# the current SNP position maybe larger then next window size since there was a dearth of SNP in the next window area. If thats the case keep sliding window until it includes the current SNP position coordinate
			elif [[ "$POS" -gt "$WINDOWSTART" ]] && [[ "$POS" -gt "$WINDOWEND" ]] && [[ ! -f tmp."$CHRNAME".txt ]]; then
				# infinite loop to keep moving window until current POS is within window size
				while :
				do
					WINDOWEND=$(echo "$WINDOWEND +$WINDOWSIZE" | bc)
					if [[ "$POS" -le "$WINDOWEND" ]]; then break; fi
				done
				echo "$POS" >> tmp."$CHRNAME".txt
				WINDOWSTART=$(echo "$WINDOWEND -$WINDOWSIZE" | bc)
			else # else SNP is outside window so analyze the tmp file

					# pick a random SNP coordinate from the temp file
					RANDOM_COORD=$(shuf -n 1 tmp."$CHRNAME".txt)
					printf "%s_%s\n" "$CHR" "$RANDOM_COORD" >> CHR."$CHRNAME".Win"$WINDOWSIZE"_SNPdist"$SNPDISTANCE".txt
					#printf "%s_%s\t%s\t%s\n" "$CHR" "$RANDOM_COORD" "$WINDOWSTART" "$WINDOWEND" >> CHR."$CHRNAME".Win"$WINDOWSIZE"_SNPdist"$SNPDISTANCE".txt

					#printf "$CHR\t$POS\t$RANDOM_COORD\t$WINDOWSTART\t$WINDOWEND\n" # debugging
					if [ ! -f tmp."$CHRNAME".txt ]; then printf "$CHR\t$POS\t$RANDOM_COORD\t$WINDOWSTART\t$WINDOWEND\n";exit 1;fi # debugging

					# move the window and calculate new end of WINDOW position
					WINDOWEND=$(echo "$WINDOWEND +$WINDOWSIZE" | bc)
					# want the next random SNP to be at least $SNPDISTANCE apart so calculate the lower bound window start position. But if it is smaller the $WINDOWEND-$WINDOWSIZE go with the later
					if [[ $(echo "$RANDOM_COORD +$SNPDISTANCE"| bc) -lt "$(echo "$WINDOWEND -$WINDOWSIZE" | bc)" ]]; then
						WINDOWSTART=$(echo "$WINDOWEND -$WINDOWSIZE" | bc)
					else
						WINDOWSTART=$(echo "$RANDOM_COORD +$SNPDISTANCE"| bc)
					fi

					# remove previous window's SNPs and start new one
					rm tmp."$CHRNAME".txt

					# if current SNP position is smaller then the windowstart and windowend coordinate then skip
					if [[ "$POS" -lt "$WINDOWSTART" ]]; then
						continue
					# if current SNP position is greater then both windowstart and windowend then keep sliding the window till it includes the current SNP position
					elif [[ "$POS" -gt "$WINDOWEND" ]]; then
						while :
						do
							WINDOWEND=$(echo "$WINDOWEND +$WINDOWSIZE" | bc)
							if [[ "$POS" -le "$WINDOWEND" ]]; then break; fi
						done
						echo "$POS" >> tmp."$CHRNAME".txt
						WINDOWSTART=$(echo "$WINDOWEND -$WINDOWSIZE" | bc)
					fi
					
					echo "$POS" >> tmp."$CHRNAME".txt
			fi
		done < <(grep -w "$CHR_SINGLE" <<< "$RAW_COORD")

		# at end of last window so deal with it and delete
		if [[ -f tmp."$CHRNAME".txt ]]; then
			# pick a random SNP coordinate from the temp file
			RANDOM_COORD=$(shuf -n 1 tmp."$CHRNAME".txt)
			printf "%s_%s\n" "$CHR" "$RANDOM_COORD" >> CHR."$CHRNAME".Win"$WINDOWSIZE"_SNPdist"$SNPDISTANCE".txt

			# move the window and calculate new end of WINDOW position
			WINDOWEND=$(echo "$WINDOWEND +$WINDOWSIZE" | bc)
			# want the next random SNP to be at least $SNPDISTANCE apart so calculate the lower bound window start position.
			WINDOWSTART=$(echo "$RANDOM_COORD +$SNPDISTANCE"| bc)
			if [[ "$WINDOWSTART" -lt "$(echo "$WINDOWEND -$WINDOWSIZE" | bc)" ]]; then WINDOWSTART="$(echo "$WINDOWEND -$WINDOWSIZE" | bc)"; fi

			rm tmp."$CHRNAME".txt
		fi

	done <<< "$CHRS"

	# analyze the last window
	if [[ -f tmp."$CHRNAME".txt ]]; then
		# pick a random SNP coordinate from the temp file
		RANDOM_COORD=$(shuf -n 1 tmp."$CHRNAME".txt)
		printf "%s_%s\n" "$CHR" "$RANDOM_COORD" >> CHR."$CHRNAME".Win"$WINDOWSIZE"_SNPdist"$SNPDISTANCE".txt

		# move the window and calculate new end of WINDOW position
		WINDOWEND=$(echo "$WINDOWEND +$WINDOWSIZE" | bc)
		# want the next random SNP to be at least $SNPDISTANCE apart so calculate the lower bound window start position.
		WINDOWSTART=$(echo "$RANDOM_COORD +$SNPDISTANCE"| bc)
		if [[ "$WINDOWSTART" -lt "$(echo "$WINDOWEND -$WINDOWSIZE" | bc)" ]]; then WINDOWSTART="$(echo "$WINDOWEND -$WINDOWSIZE" | bc)"; fi

	rm tmp."$CHRNAME".txt
	fi

done < <(cat "$CHRLIST")


#if [[ "$TYPE" == "beagle" ]]; then
#	zcat "$INFILE" | head -1
	# match the random pruned coordinate with original beagle file
#	awk 'FNR==NR {a[$1]; next} $1 in a' CHR."$CHRNAME".Win"$WINDOWSIZE"_SNPdist"$SNPDISTANCE".txt <(zcat "$INFILE")
#	rm CHR."$CHRNAME".Win"$WINDOWSIZE"_SNPdist"$SNPDISTANCE".txt
#elif [[ "$TYPE" == "mafs" ]]; then
#	awk -F '_' '{print $2}' CHR."$CHRNAME".Win"$WINDOWSIZE"_SNPdist"$SNPDISTANCE".txt
#	rm CHR."$CHRNAME".Win"$WINDOWSIZE"_SNPdist"$SNPDISTANCE".txt
#else
#	awk 'NR==FNR{c[$1$2]++;next};c[$1$2] > 0' <(awk -F '_' '{printf "%s\t%s\n", $1,$2}' CHR."$CHRNAME".Win"$WINDOWSIZE"_SNPdist"$SNPDISTANCE".txt) <(zcat "$INFILE")
#	rm CHR."$CHRNAME".Win"$WINDOWSIZE"_SNPdist"$SNPDISTANCE".txt
#fi



