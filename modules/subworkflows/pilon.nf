#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

////////////////////////////////////////////////////
/* --              Parameter setup             -- */
////////////////////////////////////////////////////

////////////////////////////////////////////////////
/* --           Load Modules                  -- */
////////////////////////////////////////////////////

include { bwa_align } from '../tools/bwa/bwa'
include { trimgalore } from '../tools/trimgalore/trimgalore'
include { pilon } from '../tools/pilon/pilon'

////////////////////////////////////////////////////
/* --           RUN MAIN WORKFLOW              -- */
////////////////////////////////////////////////////

workflow Pilon {
    take:
        pilon_input
        iteration
    
    main:
        trimgalore(
            pilon_input
        )

        bwa_align(
            pilon_input,
            trimgalore.out.reads
        )

        pilon(
            pilon_input,
            bwa_align.out.aligned_bam,
            iteration
        )

        ch_pilon = pilon_input.join(pilon.out.pilon_alignment,by:0)
        ch_pilon_out =  ch_pilon
            .map{ it -> tuple(it[0], it[5], it[2], it[3], it[4])}//sample ID, new assembly, ont fastqs, R1, R2

    emit:
        ch_pilon_out
}