#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition

process bwa_align {
    tag "${meta}"
    label 'process_high'

    container "alemenze/bwa-tools"

    input:
        tuple val(meta), path(ont_assembly), path(ont_reads), path(illumina_r1), path(illumina_r2)
        tuple val(meta), path(reads)
    
    output:
        tuple val(meta), path("*.sam"),     emit: aligned_sam
        tuple val(meta), path('*.sorted.{bam,bam.bai}'), emit: aligned_bams
        tuple val(meta), path('*.sorted.bam'), emit: aligned_bam
        tuple val(meta), path("*{flagstat,idxstats,stats}"),   emit: logs

    script:
        """
        mkdir bwa_index
        bwa index $ont_assembly -p bwa_index/${ont_assembly.baseName}

        INDEX=`find -L ./bwa_index/ -name "*.amb" | sed 's/.amb//'`
        bwa mem -t $task.cpus \$INDEX $reads > ${meta}.sam

        samtools view -hSbo ${meta}.bam ${meta}.sam
        samtools sort ${meta}.bam -o ${meta}.sorted.bam
        samtools index ${meta}.sorted.bam
        samtools flagstat ${meta}.sorted.bam > ${meta}.sorted.bam.flagstat
        samtools idxstats ${meta}.sorted.bam > ${meta}.sorted.bam.idxstats
        samtools stats ${meta}.sorted.bam > ${meta}.sorted.bam.stats
        """

}