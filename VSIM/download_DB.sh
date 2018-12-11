#!/bin/bash
#!/usr/bin/python2.7

path_to_db="./db"

# 1- Dwonload all the DB and process them:
# -------------------------------------
# 1- ClinVar
CV_file_name=$(curl ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/ | grep -o 'clinvar_[0-9]*\.vcf\.gz$' | sort -u)
wget  -O $path_to_db/CLV.vcf.gz  ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/"$CV_file_name"
zless $path_to_db/CLV.vcf.gz | grep 'CLNSIG=Pathogenic\|CLNSIG=Likely_pathogenic' > $path_to_db/CV_DB.vcf
sed -i '1s/^/##fileformat=VCFv4.1\n/' $path_to_db/CV_DB.vcf


# 2- GWAS
wget -O .$path_to_db/GW.tsv http://www.ebi.ac.uk/gwas/api/search/downloads/full 
cut -f12,13,8,11,14,15,22,25,27,28,36 $path_to_db/GW.tsv | sed -e '1s/CHR_ID/#CHROM/' -e '1s/CHR_POS/POS/' -e '1s/SNPS/ID/'  > $path_to_db/GWA2.tsv
paste <(cut -f3 $path_to_db/GWA2.tsv) <(cut -f4 $path_to_db/GWA2.tsv)   <(cut -f7 $path_to_db/GWA2.tsv)  <(cut -f1,2,5,6,8,9,10,11 ./db/GWA2.tsv) > $path_to_db/GWASData.vcf
cat $path_to_db/GWASData.vcf  | tr '\t' ',' | sed -e "s/^,/0,/" -e "s/,,/,0,/g" -e "s/,$/,0/" | tr ',' '\t' | sed 's/ /_/g'  > $path_to_db/GWASData22.vcf
python $path_to_db/GwasSeprate.py

awk -F'\t' '$1!=""' $path_to_db/GWASDataSeprate.vcf | grep -v '_x_' > $path_to_db/GWAS_DB.vcf
rm $path_to_db/GW.tsv
rm $path_to_db/GWA2.tsv 
rm $path_to_db/GWASData.vcf
rm $path_to_db/GWASDataSeprate.vcf 
rm $path_to_db/GWASData22.vcf

# 4- DIDA
curl http://dida.ibsquare.be/browse/download/DIDA_Variants_75f75773803e45027c7ad57aa5fe6dd82c0d52e371dfe78fa17317e2833566dd.csv.zip  -o $path_to_db/DidaVar.csv.zip
unzip $path_to_db/DidaVar.csv.zip  -d $path_to_db/

curl http://dida.ibsquare.be/browse/download/DIDA_Digenic-Combinations_16ddf22644411874a6371d3aa056d1c69159b9eab87f2553e5c9e166657adf3c.csv.zip -o $path_to_db/DidaComb.csv.zip
unzip $path_to_db/DidaComb.csv.zip -d $path_to_db/

mv $path_to_db/DIDA_Variants_* $path_to_db/DIDA_Variants.csv
python $path_to_db/DidaPreProcess.py
ex -sc '1i|##fileformat=VCFv4.1' -cx $path_to_db/DIDA_DB.vcf
mv $path_to_db/DIDA_Digenic-Combinations_* $path_to_db/DIDA_Digenic_comb.csv

rm $path_to_db/DIDA_Variants.csv
rm $path_to_db/DidaVar.csv.zip
rm $path_to_db/DidaComb.csv.zip
rm $path_to_db/DIDA_Variants_Update.vcf
