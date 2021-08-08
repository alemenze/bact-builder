#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process miniasm_assembly {
    tag "${meta}"
    label 'process_high'

    if (!workflow.profile=='google' && !workflow.profile=='slurm'){
        maxForks 1
    }

    publishDir "${params.outdir}/${meta}/miniasm/${replicate}",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "alemenze/ont_minis"

    input:
        tuple val(meta), path(reads)
        val(replicate)

    output:
        tuple val(meta), path('*.fasta'), emit: assembly
        tuple val(meta), path('miniasm.assembly.gfa'), emit: gfa
    
    script:
        """
        minimap2 -x ava-ont -t $params.threads $reads $reads > overlaps.paf
        miniasm -f $reads overlaps.paf > unpolished.gfa
        minipolish --threads $params.threads $reads unpolished.gfa > miniasm.assembly.gfa
        awk '/^S/{print ">"\$2"\\n"\$3}' miniasm.assembly.gfa > miniasm.assembly.fasta
        """
}