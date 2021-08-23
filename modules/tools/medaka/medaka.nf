#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process medaka {
    tag "${meta}"
    label 'process_high'

    if (!workflow.profile=='google' && !workflow.profile=='slurm'){
        maxForks 1
    }

    publishDir "${params.outdir}/medaka/${meta}",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "staphb/medaka:1.2.0"

    input:
        tuple val(meta), path(ont_assembly), path(ont_reads)
    
    output:
        tuple val(meta), path("${meta}/*consensus.fasta"), emit: consensus
    
    script:
        """
        medaka_consensus -i $ont_reads -d $ont_assembly -o ${meta} -t $task.cpus -m r941_min_high_g360
        """
}