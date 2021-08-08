#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

////////////////////////////////////////////////////
/* --              Parameter setup             -- */
////////////////////////////////////////////////////

////////////////////////////////////////////////////
/* --           Load Modules                  -- */
////////////////////////////////////////////////////

include { medaka } from '../tools/medaka/medaka'

////////////////////////////////////////////////////
/* --           RUN MAIN WORKFLOW              -- */
////////////////////////////////////////////////////

workflow Medaka {
    take:
        medaka_input
    
    main:
        medaka(
            medaka_input
        )

        ch_medaka = medaka_input.join(medaka.out.consensus)
        ch_medaka_out =  ch_medaka
            .map{ it -> tuple(it[0], it[3], it[2])}//sample ID, new assembly, ont fastqs
    emit:
        ch_medaka_out
}