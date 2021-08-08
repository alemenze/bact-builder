#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process quast {
    tag "${meta}"
    label 'process_low'

    publishDir "${params.outdir}/quast/${meta}",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "staphb/quast:5.0.2"

    input:
        tuple val(meta), path(ont_assembly), path(ont_reads), path(illumina_r1), path(illumina_r2)
    
    output:
        path("${meta}*"), emit: qc

    script:
        """
        quast.py -o $meta -b --circos $ont_assembly
        """

}