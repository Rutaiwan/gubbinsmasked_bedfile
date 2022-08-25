#!/usr/bin/env bash

# USAGE: bash gubbins_fullmask.bash gubbins.recombination_predictions.gff core-self_phast.tsv /srv/rutaiwan/acinetobacter/gubbins_fullmask

GUBBINS=$1	#gubbins output .gff file (gubbins.recombination_predictions.gff)
CORESELF=$2 #core-self mask (from snippy) with phaster output in .tsv file 
FULLMASK=$3 # eg. path directory to save your final output eg. /srv/rutaiwan/acinetobacter/gubbins_fullmask


#don't edit below this unless you know what you are doing

##Bedtools should be installed, if not then 
##conda install -c bioconda bedtools

#convert gubbins.recombination_prediction.gff to .csv file
awk -F '\t' -v OFS=, '!/^#/ {$1=$1;print}' ${GUBBINS} > gubbins.recombination_predictions.csv

#cut only column for start and stop position
cat gubbins.recombination_predictions.csv | cut -d ',' -f4-5 > gubbins_cut.csv

#convert core-self_phast.tsv to .csv file
cat ${CORESELF} | tr "\\t" "," > core-self_phast.csv 
cat core-self_phast.csv | cut -d ',' -f1 > core-self_block.csv
cat core-self_phast.csv | cut -d ',' -f2-3 > core-self_phast_cut.csv 

#add gubbins_cut.bed to core-self_phast.bed file
cat core-self_phast_cut.csv gubbins_cut.csv > gubbins_fullmask.csv
awk '!/^$/' gubbins_fullmask.csv > gubbins_fullmask_ok.csv
paste -d ',' core-self_block.csv gubbins_fullmask_ok.csv > gubbins_fullmask_complete.csv

#add correct accession number of reference (eg. CP010781) 
sed -E 's/(^|,)(,|$)/\1CP010781\2/g; s/(^|,)(,|$)/\1CP010781\2/g' gubbins_fullmask_complete.csv > gubbins_fullmask_completed.csv
rm -r gubbins_fullmask_complete.csv

#covert gubbins_fullmask_completed.csv to .bed file
sed 's/\,/\t/g' gubbins_fullmask_completed.csv > gubbins_fullmask_completed.tab
awk 'BEGIN {OFS="\t"} {print $1, $2-1, $3}' gubbins_fullmask_completed.tab > gubbins_fullmask_completed.bed

#remove all uncessory files
rm -r core-self_block.csv
rm -r core-self_phast.csv
rm -r core-self_phast_cut.csv
rm -r gubbins_cut.csv
rm -r gubbins_fullmask_completed.tab


##End of script
