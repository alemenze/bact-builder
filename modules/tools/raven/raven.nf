#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process raven_assembly {
    tag "${meta}"
    label 'process_overkill'

    if (!workflow.profile=='google' && !workflow.profile=='slurm'){
        maxForks 1
    }

    publishDir "${params.outdir}/${meta}/raven/${replicate}",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "quay.io/biocontainers/raven-assembler:1.3.0--h8b12597_0"

    input:
        tuple val(meta), path(reads)
        val(replicate)
    
    output:
        tuple val(meta), path("*.fasta"), emit: assembly

    script:
        """
        raven -t $task.cpus $reads > raven_${meta}${replicate}.fasta
        """

}