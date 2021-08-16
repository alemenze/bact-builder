# PLACEHOLDER
![GitHub last commit](https://img.shields.io/github/last-commit/alemenze/Bact-Builder)
[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A520.11.0--edge-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![run with GCP](https://img.shields.io/badge/run%20with-GCP-ffff00.svg?labelColor=000000&logo=googlecloud)](https://cloud.google.com/)
[![run with slurm](https://img.shields.io/badge/run%20with-slurm-ff4d4d.svg?labelColor=000000)](https://slurm.schedmd.com/)

## Description:
This workflow is built to provide  


## Metadata
DONT USE SPACES!
Dont use dashes in directory names either- well you can but dont use 2
Kraken can throw error if you run too many too fast without it downloading the ref

## Summary Features:

## Example Commands
### Slurm HPC execution
```
nohup nextflow -bg run /alemenze/placeholder_name -r main --samplesheet ./example_metadata.csv --outdir ./test -profile slurm --node_partition='p_lemenzad -M amareln' --gpu_active --gpus 1 > test.txt
```