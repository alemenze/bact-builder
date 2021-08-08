#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

////////////////////////////////////////////////////
/* --              Parameter setup             -- */
////////////////////////////////////////////////////

////////////////////////////////////////////////////
/* --           Load Modules                  -- */
////////////////////////////////////////////////////

include { minimap2 } from '../tools/minimap2/minimap2'
include { racon } from '../tools/racon/racon'

////////////////////////////////////////////////////
/* --           RUN MAIN WORKFLOW              -- */
////////////////////////////////////////////////////

workflow Racon {
    take:
        racon_input
        iteration
    
    main:
        minimap2(
            racon_input,
            iteration
        )

        ch_racon_in = racon_input.join(minimap2.out.aligned_sam, by:0)

        racon(
            ch_racon_in,
            iteration
        )

        ch_racon = racon_input.join(racon.out.racon_alignment,by:0)
        ch_racon_out =  ch_racon
            .map{ it -> tuple(it[0], it[3], it[2])}//sample ID, new assembly, ont fastqs

    emit:
        ch_racon_out
}