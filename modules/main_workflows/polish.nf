#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

////////////////////////////////////////////////////
/* --              Parameter setup             -- */
////////////////////////////////////////////////////

////////////////////////////////////////////////////
/* --              IMPORT MODULES              -- */
////////////////////////////////////////////////////

include { Racon } from '../subworkflows/racon'
include { Racon as Racon2 } from '../subworkflows/racon'
include { Racon as Racon3 } from '../subworkflows/racon'
include { Medaka } from '../subworkflows/medaka'
include { Pilon } from '../subworkflows/pilon'
include { Pilon as Pilon2 } from '../subworkflows/pilon'
include { Pilon as Pilon3 } from '../subworkflows/pilon'
include { quast } from '../tools/quast/quast_polished'

////////////////////////////////////////////////////
/* --           RUN MAIN WORKFLOW              -- */
////////////////////////////////////////////////////

workflow Polish {
    take:
        sample_racon
        illumina_metadata

    main:
        Racon(
            sample_racon,
            'One'
        )

        Racon2(
            Racon.out,
            'Two'
        )

        Racon3(
            Racon2.out,
            'Three'
        )

        Medaka(
            Racon3.out
        )

        ch_pilon = Medaka.out.join(illumina_metadata,by:0)

        Pilon(
            ch_pilon,
            'One'
        )

        Pilon2(
            Pilon.out,
            'Two'
        )

        Pilon3(
            Pilon2.out,
            'Three'
        )

        quast(
            Pilon3.out
        )

        polish_out = Pilon3.out
            .map{ it -> tuple(it[0], it[]) } //And end as id, polished assembly

    emit:
        polish_out

} 

