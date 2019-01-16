#!/bin/bash

# Take the input file as parameter:
echo "Mother File: $1"
echo "Father File: $2" 
child="$3"

if [ $# -eq 2 ]; then
    child=50
fi

echo "Number of simulated Children: " $child
moth=$(grep -w '#CHROM' $1 |  awk '{ print $10 }')
fath=$(grep -w '#CHROM' $2 |  awk '{ print $10 }')

bgzip $1
tabix -p vcf $1.gz
bgzip $2
tabix -p vcf $2.gz

#1- Merge the two file
vcf-merge $1.gz $2.gz > ./Simulation/Parent_$1_$2.vcf

bgzip -f ./Simulation/Parent_$1_$2.vcf
tabix -p vcf -f ./Simulation/Parent_$1_$2.vcf.gz

mkdir ./Simulation/CreatedChildren/$1_$2_children; 

#3- Creat Children
for c in $(seq 1 $child)
do
  ./Simulation/rtg-tools/rtg childsim --mother $moth --father $fath  -i ./Simulation/Parent_$1_$2.vcf.gz  -o ./Simulation/CreatedChildren/$1_$2_children/child$c.vcf.gz -t ./Simulation/1000g_v37_phase2.sdf -s child$c
done

#4- Analysis

# ClivVar 
# Find the intersect with CV Database,and Run Python of the input file for CV
bedtools intersect -wa -wb -f 1.00 -r -a ./db/CV_DB.vcf -b ./Simulation/CreatedChildren/$1_$2_children/*.vcf.gz  -filenames > ./ClinVar/CV_$1_$2
python3 ./ClinVar/CV_Children.py $1_$2 $child

# GWAS
bedtools intersect -wb -wa -f 0.50 -r -a ./db/GWAS_DB.vcf -b ./Simulation/CreatedChildren/$1_$2_children/*.vcf.gz  -filenames  > ./GWAS/GW_$1_$2
python3 ./GWAS/Gwas_children.py $1_$2 $child

# PharmGKB
bedtools intersect -wb -wa  -a  ./db/Pharm_DB.vcf -b ./Simulation/CreatedChildren/$1_$2_children/*.vcf.gz  -filenames > ./PharmGKB/PhG_$1_$2
python3 ./PharmGKB/PharmGKB_Children.py $1_$2 $child

# Dida
bedtools intersect -wa -wb  -a ./db/DIDA_DB.vcf -b ./Simulation/CreatedChildren/$1_$2_children/*.vcf.gz  -filenames > ./DIDA/Di_$1_$2
python3 ./DIDA/Dida_Children.py $1_$2 $child


# 5- MCAP annotation
# Run Annovar to annotae the file with Mendelian Clinically Applicable Pathogenicity (M-CAP) Score
mkdir ./ChildResults/mcap_$1_$2; 

rm ./Simulation/CreatedChildren/$1_$2_children/*.vcf.gz.tbi
gunzip ./Simulation/CreatedChildren/$1_$2_children/*
for file in ./Simulation/CreatedChildren/$1_$2_children/* ; do
	x=$(basename $file)	
	#sed -i "" 's/Chr//g' ./Simulation/CreatedChildren/$1_$2_children/$x
 	perl ./annovar/table_annovar.pl ./Simulation/CreatedChildren/$1_$2_children/$x  ./annovar/humandb/ -buildver hg19 -out ./ChildResults/mcap_$1_$2/MCAP_$x 	 -remove -protocol mcap -operation f -nastring . -vcfinput
    	rm ./ChildResults/mcap_$1_$2/MCAP_$x.avinput
	rm ./ChildResults/mcap_$1_$2/MCAP_$x.hg19_multianno.txt
	perl MCAP_filter.pl ./ChildResults/mcap_$1_$2/MCAP_$x.hg19_multianno.vcf 0.025 > ./ChildResults/mcap_$1_$2/filtered_$x
	rm  ./ChildResults/mcap_$1_$2/MCAP_$x.hg19_multianno.vcf
done

cat ./ChildResults/mcap_$1_$2/*.vcf > ./ChildResults/mcap_$1_$2/MCAP_AllChild.vcf

python3 ./ChildResults/MCAP_Combine.py $1_$2 $child
rm -rfv ./ChildResults/mcap_$1_$2
rm -rfv ./Simulation/CreatedChildren/$1_$2_children
rm ./Simulation/Parent_$1_$2.*
rm ./ChildResults/temp.txt


# 6- Combine all created files:
python3 ./ChildResults/CombineSimResult.py $1_$2 

# 7- Vislization
# Prepare the file for Vis
python3 ./VisFiles/PrepareJsonChild.py $1_$2

# Creat Json File
python3 ./VisFiles/JsonChild.py $1_$2 > ./VisFiles/$1-$2.json

#echo "Done"
# visualize

rm ./VisFiles/ToJsonChild_$1_$2.txt 
rm ./VisFiles/FinalChild_$1_$2
