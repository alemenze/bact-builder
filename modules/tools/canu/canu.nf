#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process canu_assembly {
    tag "${meta}"
    label 'process_overkill'

    publishDir "${params.outdir}/${meta}/canu/${replicate}",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }
    if (!workflow.profile=='google' && !workflow.profile=='slurm'){
        maxForks 1
    }

    container "staphb/canu-racon"

    input:
        tuple val(meta), path(reads)
        val(replicate)
    
    output:
        tuple val(meta), path("${meta}_canu/*.contigs.fasta"), emit: assembly
        tuple val(meta), path("${meta}_canu/*.gfa"), emit: gfa

    script:
        """
        canu -p ${meta} -d ${meta}_canu genomeSize=${params.assembly_genome_size} useGrid=false -nanopore $reads
        """

}