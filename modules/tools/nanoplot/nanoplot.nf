#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process nanoplot {
    tag "${sequencing_summary}"
    label 'process_low'

    publishDir "${params.outdir}/nanoplot/${run}/${type}/${meta}",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }
    
    container "staphb/nanoplot:1.33.0"

    input:
        tuple val(meta), path(reads), val(run)
        val(type)
    
    output:
        path "*.{png, html, txt, log}", emit: report
    
    script:
        """
        NanoPlot --fastq $reads
        """
 
}