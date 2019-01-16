# VSIM

Visualization and Simulation of Variants in Personal Genomes With an Application to Premarital Testing

This user guide have been tested on Ubuntu version 16.04.

## Hardware requirements
 - At least 32 GB RAM to process and accommodate the necessary databases for annotation.

## Software requirements (for native installation)
 - Any Unix-based operating system
 - Java 8
 - Python 3
 - Groovy Version: 2.5.1, JVM: 1.8.0_121
 
## Database requirements 
1. Download [MCAP](https://drive.google.com/file/d/13N0meotI2rTfbLt-GuL1ic-O3uokLvwH/view?usp=sharing) database into the directory `./VSIM/annovar/humandb` 

2. Download the Human reference genomes [1000g_v37_phase2.sdf.zip](https://s3.amazonaws.com/rtg-datasets/references/1000g_v37_phase2.sdf.zip) into the directory `./VSIM/Simulation` 

3. Download and run the script [download_DB.sh](https://github.com/azzatha/VSIM/blob/master/VSIM/download_DB.sh) 
```
     $chmod +x download_DB.sh
     $./download_DB.sh
```
Make sure that all the database inside the directory `./VSIM/db` 

4. Download script [loadModeInh.groovy](https://github.com/azzatha/VSIM/blob/master/VSIM/ClinVar/loadModeInh.groovy) to `./VSIM/ClinVar` folder. Then Run the script from `VSIM` folder:
```
    groovy ./ClinVar/loadModeInh.groovy | grep "^OMIM" > ./ClinVar/omim_mode.txt
```

## Docker Container
1. Install [Docker](https://docs.docker.com/)
2. Download the database requirements
3. Build VSIM docker image:
```
   docker build -t vsim-web .
```
4. Run VSIM-web
```
   docker run -it -p 80:80 vsim-web
```

## Usage:

- VSIM accepts a VCF file as input, annotates the variants in the VCF file, and then visualizes the results on a chromosomal ideogram.
- To run the tool, the user needs to provide a **VCF file** to annotating and Visualizing Personal Genomic Data as showed in [Example1](https://github.com/azzatha/VSIM/blob/master/vsim.com/result1example.html).
The following figure provides an example of the output.


![indvres](https://user-images.githubusercontent.com/31382680/49799724-add17400-fd56-11e8-8f56-6a1136f71923.png)


- For simulating child cohorts and the application to premarital testing, the user needs to provide two VCF files, represent the mother and father genomics sequence data. Then the tool will simulate a population of children and analysis the result here is an example [Example2](https://github.com/azzatha/VSIM/blob/master/vsim.com/result2example.html).
The following figure provides an example of the simulation result. 

<img width="1376" alt="simres" src="https://user-images.githubusercontent.com/31382680/49799992-72837500-fd57-11e8-95ca-bf374842363f.png">


- VSIM generates chromosomal views based on chromosomal ideograms and shows the chromosomal positions at which a functional variant has been found. 
- Different categories of variants are shown in different colors, and it is possible to filter variants by their type (whether they are Mendelian disease variants, pharmacogenomic variants, etc.). 
- Users are able to obtain additional information about variants when selecting a single variant, and can follow a hyper-link to a website with additional information and evidence about the type of variant. 
- You can find the details of updated rtg-simulation here: [RTG-Simulation-tool](https://github.com/bio-ontology-research-group/RTG-Simulation-tool)
