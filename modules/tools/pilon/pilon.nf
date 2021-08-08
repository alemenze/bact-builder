#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process pilon {
    tag "${meta}"
    label 'process_high'

    if (!workflow.profile=='google' && !workflow.profile=='slurm'){
        maxForks 1
    }

    publishDir "${params.outdir}/pilon/${meta}/${iteration}",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "staphb/pilon:1.23.0"

    input:
        tuple val(meta), path(ont_assembly), path(ont_reads), path(illumina_r1), path(illumina_r2)
        tuple val(meta), path(aligned_bam)
        val(iteration)
    
    output:
        tuple val(meta), path("*.fasta"), emit: pilon_alignment
    
    script:
        """
        pilon --genome $ont_assembly --threads $task.cpus --frags $aligned_bam --changes --output ${meta}_${iteration}_pilon --fix all
        """
}