#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process trycycler{
    tag "${meta}"
    label 'process_overkill_long'

    if (!workflow.profile=='google' && !workflow.profile=='slurm'){
        maxForks 1
    }

    publishDir "${params.outdir}/trycycler/${meta}",
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
        tuple val(meta), path("${meta}_consensus.fasta"), emit: consensus
    
    script:
        """
        trycycler cluster --assemblies $assemblies --reads $input_reads --min_contig_depth $params.min_contig_depth --out_dir ./trycycler
        trycycler reconcile --reads $input_reads --cluster_dir ./trycycler/cluster_001/ --max_length_diff $params.max_length_diff --min_identity $params.min_identity --max_add_seq $params.max_add_seq --max_indel_size $params.max_indel_size
        trycycler msa --cluster_dir ./trycycler/cluster_001/
        trycycler partition --reads $input_reads --cluster_dirs ./trycycler/cluster_001/
        trycycler consensus --cluster_dir ./trycycler/cluster_001/
        cat ./trycycler/cluster_001//7_final_consensus.fasta > ${meta}_consensus.fasta
        """
}