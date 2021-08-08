#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process filtlong{
    tag "${meta}"
    label 'process_medium'

    publishDir "${params.outdir}/filtlong/${run}",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "nanozoo/filtlong:0.2.0--0c4cbe3"

    input:
        tuple val(meta), path(reads), val(run)
    
    output:
        tuple val(meta), path("*.trim.fastq.gz"), emit: fastq
    
    script:
        """
        filtlong --min_length $params.min_length --min_mean_q $params.min_mean_q $reads | gzip > ${meta}.trim.fastq.gz
        """
}