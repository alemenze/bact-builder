#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process miniasm_assembly {
    tag "${meta}"
    label 'process_overkill'

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
        tuple val(meta), path('*.assembly.gfa'), emit: gfa
    
    script:
        """
        minimap2 -x ava-ont -t $task.cpus $reads $reads > overlaps.paf
        miniasm -f $reads overlaps.paf > unpolished.gfa
        minipolish --threads $task.cpus $reads unpolished.gfa > miniasm_${meta}${replicate}.assembly.gfa
        awk '/^S/{print ">"\$2"\\n"\$3}' miniasm_${meta}${replicate}.assembly.gfa > miniasm_${meta}${replicate}.assembly.fasta
        """
}