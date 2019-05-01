#!/bin/bash

########

## H12 script
H12=/storage/jae.youngchoi/PROGRAMS_AND_SCRIPTS/PROGRAMS/SelectionHapStats/scripts/H12_H2H1.py

##tped filename
TFILE=COREPOP.combined.ALLCHR.SNP.FILTERED.PASS.MaxMissing0.8.impute_phased.popN

## list of indv to keep in PLINK format. Doesn't need to exist (optional)
#KEEP=N.txt

# is it imputed? Yes for (1) No for (0)
IMPUTE=1

# outname
OUTNAME="popN"

########

while read -r CHR; do
	# extract sample of interest into plink
	mkdir "$CHR"

	if [[ "$IMPUTE" -eq 0 ]]; then

		if [[ -f "$KEEP" ]]; then
			plink2 --tfile "$TFILE" --allow-extra-chr --recode --tab --transpose --chr "$CHR" --keep "$KEEP" --out "$CHR"/"$OUTNAME"."$CHR"
		else
			plink2 --tfile "$TFILE" --allow-extra-chr --recode --tab --transpose --chr "$CHR" --out "$CHR"/"$OUTNAME"."$CHR"
		fi

		cd "$CHR"

		# convert the tped file to input format for H12 script
		INFILE=$(printf "${OUTNAME}.${CHR}")
		awk -F'\t' -v OFS="," '{ for (i = 5; i <= NF; i++){split($i,GT," ");if(GT[1]==0){$i="N"}else if(GT[1]==GT[2]){$i=GT[1]}else{$i="N"}}; print $0}' "$INFILE".tped | cut -d ',' -f 4- > "$INFILE".H12_input.txt

	else
		if [[ -f "$KEEP" ]]; then
			plink2 --tfile "$TFILE" --allow-extra-chr --recode --transpose --chr "$CHR" --keep "$KEEP" --out "$CHR"/"$OUTNAME"."$CHR"
		else
			plink2 --tfile "$TFILE" --allow-extra-chr --recode --transpose --chr "$CHR" --out "$CHR"/"$OUTNAME"."$CHR"
		fi
		cd "$CHR"

		INFILE=$(printf "${OUTNAME}.${CHR}")
		awk '{for(x=4;x<=NF;x++)if(x % 2 == 0)printf "%s", $x (x == NF || x == (NF-1)?"\n":" ")}' "$INFILE".tped | tr ' ' ',' > "$INFILE".H12_input.txt

	fi

        ### H12 statistics
        # calculate H12 stats
	WINDOW=50; JUMP=5
	python "$H12" "$INFILE".H12_input.txt "$(wc -l < "$INFILE".tfam)" -w "$WINDOW" -j "$JUMP" -o "$INFILE".window"$WINDOW"_jump"$JUMP".H12_output.txt
        WINDOW=100; JUMP=10
        python "$H12" "$INFILE".H12_input.txt "$(wc -l < "$INFILE".tfam)" -w "$WINDOW" -j "$JUMP" -o "$INFILE".window"$WINDOW"_jump"$JUMP".H12_output.txt
        WINDOW=500; JUMP=50
        python "$H12" "$INFILE".H12_input.txt "$(wc -l < "$INFILE".tfam)" -w "$WINDOW" -j "$JUMP" -o "$INFILE".window"$WINDOW"_jump"$JUMP".H12_output.txt
#        WINDOW=1000; JUMP=100
#        python "$H12" "$INFILE".H12_input.txt "$(wc -l < "$INFILE".tfam)" -w "$WINDOW" -j "$JUMP" -o "$INFILE".window"$WINDOW"_jump"$JUMP".H12_output.txt
#        WINDOW=2000; JUMP=200
#        python "$H12" "$INFILE".H12_input.txt "$(wc -l < "$INFILE".tfam)" -w "$WINDOW" -j "$JUMP" -o "$INFILE".window"$WINDOW"_jump"$JUMP".H12_output.txt

	cd ..

done < <(awk '{print $1}' "$TFILE".tped | uniq)

