#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process racon {
    tag "${meta}"
    label 'process_high'

    if (!workflow.profile=='google' && !workflow.profile=='slurm'){
        maxForks 1
    }

    publishDir "${params.outdir}/racon/${meta}/${iteration}",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "staphb/racon:1.4.20"

    input:
        tuple val(meta), path(ont_assembly), path(ont_reads), path(aligned_sam)
        val(iteration)
    
    output:
        tuple val(meta), path("*.fasta"), emit: racon_alignment
    
    script:
        """
        racon -m 8 -x -6 -g -8 -w 500 -t $task.cpus $ont_reads $aligned_sam $ont_assembly > ${meta}_${iteration}_racon.fasta
        """
}