#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition

process minimap2 {
    tag "${meta}"
    label 'process_high'

    container "staphb/minimap2:2.21"

    input:
        tuple val(meta), path(ont_assembly), path(ont_reads)
        val(iteration)
    
    output:
        tuple val(meta), path("${meta}_${iteration}.sam"),     emit: aligned_sam

    script:
        """
        minimap2 -ax map-ont -t $task.cpus $ont_assembly $ont_reads > ${meta}_${iteration}.sam
        """

}