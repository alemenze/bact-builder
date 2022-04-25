# Bact-Builder
![GitHub last commit](https://img.shields.io/github/last-commit/alemenze/bact-builder)
[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A520.11.0--edge-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![run with GCP](https://img.shields.io/badge/run%20with-GCP-ffff00.svg?labelColor=000000&logo=googlecloud)](https://cloud.google.com/)
[![run with slurm](https://img.shields.io/badge/run%20with-slurm-ff4d4d.svg?labelColor=000000)](https://slurm.schedmd.com/)

## Description:
This workflow is built to provide a comprehensive workflow for bacterial de novo genome construction, including multiple assembly methods with consensus generation and polishing. 

## Metadata
Setting up this pipeline for execution involves establishing an appropriate metadata file. This is a csv file that enables parsing the files correctly together and labelling samples appropriately. 

Follow traditional naming restrictions- IE dont use special characters, spaces etc. 

## Tutorial and Wiki
A tutorial on executing Bact-Builder can be [found here](https://github.com/alemenze/bact-builder/tree/main/docs/execution_tutorial.md), with additional execution information as well as parameter details found on [the Bact-Builder wiki here](https://github.com/alemenze/bact-builder/wiki). 

## Summary Features:
### Basecalling
- Basecalling and demultiplexing with [guppy](https://community.nanoporetech.com/protocols/Guppy-protocol/v/gpb_2003_v1_revt_14dec2018)
- Sample and trimming QC with [pycoQC](https://adrienleger.com/pycoQC/), [fastp](https://github.com/OpenGene/fastp), [NanoPlot](https://github.com/wdecoster/NanoPlot), and [Filtlong](https://github.com/rrwick/Filtlong).
- Predictive QC and contaminant detection with [Kraken2](https://ccb.jhu.edu/software/kraken2/)
### Assembly
- Random subsampling of reads for multiple assemblies with [Rasusa](https://github.com/mbhall88/rasusa)
- Replicate assembly with [Flye](https://github.com/fenderglass/Flye), [Canu](https://github.com/marbl/canu), [Raven](https://github.com/lbcb-sci/raven), and [Miniasm/minimap2](https://github.com/lh3/miniasm)
- Assembly consensus with [Trycycler](https://github.com/rrwick/Trycycler)
- Assembly QC with [Quast](http://bioinf.spbau.ru/quast)
### Polishing
- 3x polishing steps with [Racon](https://github.com/isovic/racon) for ONT reads
- 1x polishing step with [Medaka](https://github.com/nanoporetech/medaka) for ONT reads
- 3x poilishing steps with [Pilon](https://github.com/broadinstitute/pilon) for Illumina reads

