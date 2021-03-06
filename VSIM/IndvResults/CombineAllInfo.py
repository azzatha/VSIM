import pandas as pd
import numpy as np

import sys
from pathlib import Path

fileName = sys.argv[-1]

cvf = Path("./IndvResults/FinalCV_"+str(fileName))
gwf = Path("./IndvResults/FinalGW_"+str(fileName))
phf = Path("./IndvResults/FinalPhG_" + str(fileName))
dif = Path("./IndvResults/FinalDi_"+str(fileName))
mcapf = Path("./IndvResults/FinalMCAP_"+str(fileName))

if cvf.is_file():
    cv = pd.read_csv("./IndvResults/FinalCV_"+str(fileName),sep="\t")
else:
    cv = pd.DataFrame(columns=['#CHROM','POS','ID','REF','ALT','QUAL','FILTER','INFO','FORMAT','GT'])

if gwf.is_file():
    gwas = pd.read_csv("./IndvResults/FinalGW_"+str(fileName),sep="\t")
else:
    gwas = pd.DataFrame(columns=['#CHROM','POS','ID','REF','ALT','QUAL','FILTER','INFO','FORMAT','GT'])

if phf.is_file():
    pharm = pd.read_csv("./IndvResults/FinalPhG_" + str(fileName), sep="\t")
else:
    pharm = pd.DataFrame(columns=['#CHROM','POS','ID','REF','ALT','QUAL','FILTER','INFO','FORMAT','GT'])

if dif.is_file():
    dida = pd.read_csv("./IndvResults/FinalDi_" + str(fileName), sep="\t")
else:
    dida = pd.DataFrame(columns=['#CHROM','POS','ID','REF','ALT','QUAL','FILTER','INFO','FORMAT','GT'])

if mcapf.is_file():
    mcap = pd.read_csv("./IndvResults/FinalMCAP_" + str(fileName), sep="\t")
else:
    mcap = pd.DataFrame(columns=['#CHROM','POS','ID','REF','ALT','QUAL','FILTER','INFO','FORMAT','GT'])

mcap['#CHROM'].astype(str)
dida['#CHROM']= dida['#CHROM'].astype(str)
pharm['#CHROM']= pharm['#CHROM'].astype(str)
gwas['#CHROM']= gwas['#CHROM'].astype(str)
cv['#CHROM']= cv['#CHROM'].astype(str)

Combine = pd.merge = pd.concat([cv, gwas,pharm,dida,mcap], axis=0)
Combine = Combine.sort_values('#CHROM')
Combine = Combine.replace(' ', '_', regex=True)
Combine.to_csv("./VisFiles/Final_"+str(fileName), index = False, sep="\t")