# VSIM

Visualization and Simulation of Variants in Personal Genomes With an Application to Premarital Testing

This user guide have been tested on Ubuntu version 16.04.

## Hardware requirements
 - At least 32 GB RAM to process and accommodate the necessary databases for annotation.

## Software requirements (for native installation)
 - Any Unix-based operating system
 - Java 8
 - Python 3
 
## Database requirements 
1. Download [MCAP]() database file.
2. Download and run the script [download_DB.sh](https://github.com/azzatha/VSIM/blob/master/VSIM/download_DB.sh) 
```
     $chmod +x download_DB.sh
     $./download_DB.sh
```
Make sure that all the database inside the directory`./VSIM/db` 

3. Download script [loadModeInh.groovy]() to ClinVar folder
Run the script
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
- To run the tool, the user needs to provide a **VCF file** to annotating and Visualizing Personal Genomic Data as showed in [Example1]() Figure 1 provides an example of the output.

- For simulating child cohorts and the application to premarital testing, the user needs to provide two VCF files, represent the mother and father genomics sequence data. Then the tool will simulate a population of children and analysis the result here is an example [Example2](). Figure 2 provides an example of the simulation result. 

- VSIM generates chromosomal views based on chromosomal ideograms and shows the chromosomal positions at which a functional variant has been found. 
- Different categories of variants are shown in different colors, and it is possible to filter variants by their type (whether they are Mendelian disease variants, pharmacogenomic variants, etc.). 
- Users are able to obtain additional information about variants when selecting a single variant, and can follow a hyper-link to a website with additional information and evidence about the type of variant. 
