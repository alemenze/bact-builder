#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process fastp {
    tag "${meta}"
    label 'process_low'

    publishDir "${params.outdir}/fastp/${type}",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "biocontainers/fastp:v0.20.1_cv1"

    input:
        tuple val(meta), path(reads)
        val(type)
    
    output:
        tuple val(meta), path("*.html"), emit: html

    script:
        """
        fastp -i $reads -h ${meta}.html -A -L -Q 
        """

}