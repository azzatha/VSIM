#!/bin/bash
# Indv Work: This code will generate the final files for vis:

# 1- Update all the DB and process them
# -------------------------------------

# Take the input file as parameter:
echo "start $1"

# 1- CV Work
# Load New OMIM:
#groovy ./ClinVar/loadModeInh.groovy | grep "^OMIM" > ./1-ClinVar/omim_mode.txt

# Find the intersect with CV Database,and Run Python of the input file for CV
bedtools intersect -wb -f 1.00 -r -a ./db/CV_DB.vcf -b $1 > ./ClinVar/clinvar_Data.vcf
cut -f9,10,11,12,13,14,15,16,17,18 ./ClinVar/clinvar_Data.vcf > ./ClinVar/clinvar_Data2.vcf
egrep -v "^#" ./db/CV_DB.vcf > ./db/CV_Pathogenic_.vcf
cat ./db/headerCV.txt ./db/CV_Pathogenic_.vcf >  ./db/CV_DB_Anno.vcf
cat ./ClinVar/headerInfo.txt ./ClinVar/clinvar_Data2.vcf > ./ClinVar/clinvar_Data_Annotate.vcf

#Annotate the resulting file:
bgzip ./db/CV_DB_Anno.vcf
tabix -p vcf ./db/CV_DB_Anno.vcf.gz
/usr/bin/vcfanno_linux64 -permissive-overlap ./db/conf_ClinVar.toml  ./ClinVar/clinvar_Data_Annotate.vcf > ./ClinVar/Annotat_$1
egrep -v "^#" ./ClinVar/Annotat_$1 > ./ClinVar/Annotat_$1_noHeader.vcf
python ./ClinVar/CV_Individual.py $1

rm ./ClinVar/clinvar_Data.vcf 
rm ./ClinVar/clinvar_Data2.vcf
rm ./ClinVar/Annotat_$1
rm ./ClinVar/Annotat_$1_noHeader.vcf
rm ./db/CV_Pathogenic_.vcf
rm ./db/CV_DB_Anno.vcf.gz
rm ./db/CV_DB_Anno.vcf.gz.tbi

# 2- GWAS Work
# Find the intersect with GWAS  Database, and Run Python of the input file for GW
bedtools intersect -wb -wa -f 1.0 -r -a ./db/GWAS_DB.vcf  -b $1 > ./GWAS/gwas_Data_$1
python ./GWAS/GWAS_Individual.py $1 

# 3- PharmGKB Work
# Find the intersect with PharmGKB  Database, and Run Python of the input file for PG
bedtools intersect -wb -wa -f 1.0 -r -a ./db/Pharm_DB.vcf -b  $1 > ./PharmGKB/PhG_$1
python ./PharmGKB/PharmGKB_Individual.py $1

# 4- Dida Work
# Find the intersect with Dida  Database, and Run Python of the input file for Di
bedtools intersect -wa -wb -f 1.00 -r -a ./db/DIDA_DB.vcf -b  $1 > ./DIDA/Di_$1
python ./DIDA/DIDA_Individual.py $1

# 5- MCAP annotation
# Run Annovar to annotae the file with Mendelian Clinically Applicable Pathogenicity (M-CAP) Score
perl ./annovar/table_annovar.pl  $1 ./annovar/humandb/ -buildver hg19 -out MCAP_$1 -remove -protocol mcap -operation f -nastring . -vcfinput

rm MCAP_$1.avinput
rm MCAP_$1.hg19_multianno.txt

# Take all the predicted Pathognic, the Recommended Pathogenicity threshold M-CAP > 0.025
perl MCAP_filter.pl MCAP_$1.hg19_multianno.vcf 0.025 > ./IndvResults/MCAP_$1
rm  MCAP_$1.hg19_multianno.vcf

# Add the header info
cat ./IndvResults/header.txt ./IndvResults/MCAP_$1 > ./IndvResults/FilterMCAP_$1
python ./IndvResults/MCAPRes.py $1

rm ./IndvResults/MCAP_$1
rm ./IndvResults/FilterMCAP_$1

# 6- Combine all created files:
python ./IndvResults/CombineAllInfo.py $1

# 7- Prepare the file for Vis
python ./VisFiles/PrepareJForJson.py $1

# 8- Creat Json File
python ./VisFiles/JsonIndv.py $1 > ./VisFiles/$1.json

#Vislization

rm ./DIDA/Di_$1
rm ./PharmGKB/PhG_$1
rm ./GWAS/gwas_Data_$1
