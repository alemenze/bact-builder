#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition

process trimgalore {
    tag "${meta}"
    label 'process_medium'

    container "quay.io/biocontainers/trim-galore:0.6.6--0"

    input:
        tuple val(meta), path(ont_assembly), path(ont_reads), path(illumina_r1), path(illumina_r2)

    output:
        tuple val(meta), path("*.fq.gz"),       emit: reads
        tuple val(meta), path("*report.txt"),   emit: log
        tuple val(meta), path("*.html"),        emit: html 
        tuple val(meta), path("*.zip") ,        emit: zip

    script:
        """
        trim_galore \\
            --cores ${task.cpus} \\
            --fastqc \\
            --paired \\
            --gzip \\
            $illumina_r1 $illumina_r2
        """
}