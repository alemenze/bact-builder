#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process trycycler_cluster{
    tag "${meta}"

    if (!workflow.profile=='google' && !workflow.profile=='slurm'){
        maxForks 1
    }

    publishDir "${params.outdir}/trycycler/${meta}/clusters",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "alemenze/trycycler-docker"

    input:
        tuple val(meta), path(input_reads), path(assemblies)
        
    output:
        tuple val(meta), path("trycycler/cluster_001", type:'dir'), emit: cluster_dirs
        path("trycycler/**/**/*.fasta"), emit: out_files
        path("trycycler/*newick"), emit: out_trees
    
    script:
        """
        trycycler cluster --assemblies $assemblies --reads $input_reads --min_contig_depth $params.min_contig_depth --out_dir ./trycycler
        """
}

process trycycler_reconcile{
    tag "${meta}"

    if (!workflow.profile=='google' && !workflow.profile=='slurm'){
        maxForks 1
    }

    publishDir "${params.outdir}/trycycler/${meta}/reconcile",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "alemenze/trycycler-docker"

    input:
        tuple val(meta), path(trycycler_assemblies), path(input_reads)
    
    output:
        tuple val(meta), path("trycycler/cluster_001", type:'dir'), emit: cluster_dirs 
    
    script:
        """
        trycycler reconcile --reads $input_reads --cluster_dir $reads --max_length_diff $params.max_length_diff --min_identity $params.min_identity --max_add_seq $params.max_add_seq --max_indel_size $params.max_indel_size
        """
}

process trycycler_msa{
    tag "${meta}"

    if (!workflow.profile=='google' && !workflow.profile=='slurm'){
        maxForks 1
    }

    publishDir "${params.outdir}/trycycler/${meta}/msa",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "alemenze/trycycler-docker"

    input:
        tuple val(meta), path(trycycler_assemblies)
    
    output:
        tuple val(meta), path("trycycler/cluster_001", type:'dir'), emit: cluster_dirs
    
    script:
        """
        trycycler msa --cluster_dir $trycycler_assemblies --out_dir ./trycycler 
        """
}

process trycycler_partition{
    tag "${meta}"

    if (!workflow.profile=='google' && !workflow.profile=='slurm'){
        maxForks 1
    }

    publishDir "${params.outdir}/trycycler/${meta}/partition",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "alemenze/trycycler-docker"

    input:
        tuple val(meta), path(trycycler_assemblies), path(input_reads)

    output:
        tuple val(meta), path("trycycler/cluster_001", type:'dir'), emit: cluster_dirs
    
    script:
        """
        trycycler partition --reads $input_reads --cluster_dirs $trycycler_assemblies --out_dir ./trycycler
        """
}

process trycycler_consensus{
    tag "${meta}"

    if (!workflow.profile=='google' && !workflow.profile=='slurm'){
        maxForks 1
    }

    publishDir "${params.outdir}/trycycler/${meta}/consensus",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "alemenze/trycycler-docker"

    input:
        tuple val(meta), path(trycycler_assemblies)
    
    output:
        tuple val(meta), path("*.fasta"), emit: consensus
    
    script:
        """
        trycycler consensus --cluster_dir $trycycler_assemblies
        cat $trycycler_assemblies/7_final_consensus.fasta > ${meta}_consensus.fasta
        """
}