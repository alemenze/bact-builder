#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

////////////////////////////////////////////////////
/* --              Parameter setup             -- */
////////////////////////////////////////////////////

////////////////////////////////////////////////////
/* --           Load Modules                  -- */
////////////////////////////////////////////////////

include { Kraken2_db_build } from '../tools/kraken/kraken'
include { Kraken2 } from '../tools/kraken/kraken'
include { Krona } from '../tools/kraken/kraken'

////////////////////////////////////////////////////
/* --           RUN MAIN WORKFLOW              -- */
////////////////////////////////////////////////////

workflow Kraken {
    take:
        reads
        kraken_name
    
    main:
        Kraken2_db_build(
            params.kraken_db,
            kraken_name
        )

        Kraken2(
            reads,
            Kraken2_db_build.out.kraken2_ch,
            'single'
        )

        Krona(
            Kraken2.out.kraken2krona
        )
}