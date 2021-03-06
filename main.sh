#!/bin/bash

## the name of the master directory holding inputs, outputs and processing codes
toolName="gatk4wxscnv"
## the name of the batch
batchName="LUAD.b1"
## the name the directory holding the processing code
toolDirName=${toolName}"."${batchName}
## the path to the master directory
mainRunDir="/diskmnt/Projects/CPTAC3CNV/"${toolName}"/"
## the path to the directory holding the manifest for BAM files
bamMapDir="/diskmnt/Projects/cptac_downloads/data/GDC_import/import.config/CPTAC3.b1.LUAD/"
## the name of the manifiest for BAM files
bamMapFile="CPTAC3.b1.LUAD.BamMap.dat"
## the path to the directory holding the reference fasta file
refDir=" /diskmnt/Projects/Users/mwyczalk/data/docker/data/A_Reference/"
## the name of the reference fasta file
refFile="Homo_sapiens_assembly19.fasta"
## the path to the directory holding the exome target bed file
exomeBedDir="/diskmnt/Projects/cptac/gatk4wxscnv/target_bed/"
## the name of the exome target bed file
exomeBedFile="nexterarapidcapture_exome_targetedregions_v1.2.bed"
## the type of the BAM file
bamType="WXS"
## the path to the java binary
javaPath="/usr/bin/java"
## the path to the gatk jar file
gatkPath="/home/software/gatk-4.beta.5/gatk-package-4.beta.5-local.jar"
## the path to the parent directory containing input BAM files
bamDir="/diskmnt/Projects/cptac_downloads/data/GDC_import"
## the name of the docker image
imageName="yigewu/gatk4wxscnv:v1"
## the path to the binary file for the language to run inside docker container
binaryFile="/miniconda3/bin/python3"
## the date of the processing
id=$1
## the name of the processing version
version=1.1
## the file prefix for the gene-level CNV report
genelevelFile="gene_level_CNV"
## the file containing the cancer types to be processed
cancerType="cancer_types.txt"

## get dependencies into inputs directory, so as to not potentially change the original dependency files
cm="bash get_dependencies.sh ${mainRunDir} ${bamMapDir} ${bamMapFile} ${refDir} ${refFile} ${exomeBedDir} ${exomeBedFile}"
echo ${cm}

## split the paths to the bam files into batches
cm="bash split_bam_path.sh ${mainRunDir} ${bamMapFile} ${bamType} ${cancerType}"
echo ${cm}

## create configure files
cm="bash create_config.sh ${mainRunDir} ${bamMapFile} ${bamType} ${javaPath} ${gatkPath} ${refFile} ${exomeBedFile} ${batchName} ${cancerType}"
echo ${cm}

## use tmux to run jobs
j="LUAD"
cm="bash run_tmux.sh ${id} ${j} /home/software/gatk4wxscnv/ gatk4wxscnv.py  '--config ${mainRunDir}${toolDirName}/config_${j}.yml' '${mainRunDir}outputs/${batchName}/${j}' ${toolDirName} ${mainRunDir} ${bamDir} ${imageName} ${binaryFile}"
echo ${cm}

## get gene-level copy number values
cm="bash get_gene_level_cnv.sh ${mainRunDir} ${bamMapFile} ${bamType} ${javaPath} ${gatkPath} ${refFile} ${exomeBedFile} ${batchName} ${genelevelFile} ${version} ${id}"
echo ${cm}

## format outputs and copy to deliverables
cm="bash rename_output.sh ${mainRunDir} ${bamMapFile} ${toolName} ${batchName}"
echo ${cm}

## clean up docker containers
cm="bash clean_docker_containers.sh ${imageName}"
echo $cm
