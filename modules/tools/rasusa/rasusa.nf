#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process random_subset {
    tag "${meta}"
    label 'process_medium'

    publishDir "${params.outdir}/rasusa/${replicate}",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container 'mbhall88/rasusa:0.3.0'

    input:
        tuple val(meta), path(reads)
        val(replicate)

    output:
        tuple val(meta), path("*.subsamp.fastq.gz"), emit: fastq

    script:

        """
        rasusa --input $reads \\
            --coverage $params.subset_cov --genome-size $params.genome_size \\
            --output ${meta}.subsamp.fastq.gz
        """


}