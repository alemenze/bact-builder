#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process flye_assembly {
    tag "${meta}"
    label 'process_overkill'

    if (!workflow.profile=='google' && !workflow.profile=='slurm'){
        maxForks 1
    }

    publishDir "${params.outdir}/${meta}/flye/${replicate}",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "staphb/flye:2.8"

    input:
        tuple val(meta), path(reads)
        val(replicate)
    
    output:
        tuple val(meta), path("${meta}_flye/*.fasta"), emit: assembly
        tuple val(meta), path("${meta}_flye/*.gfa"), emit: gfa
    
    script:
        """
        flye --nano-raw $reads --genome-size $params.assembly_genome_size --plasmids --o ${meta}_flye --threads $task.cpus
        """

}