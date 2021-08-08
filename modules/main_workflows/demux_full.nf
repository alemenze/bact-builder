#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

////////////////////////////////////////////////////
/* --              Parameter setup             -- */
////////////////////////////////////////////////////

////////////////////////////////////////////////////
/* --              IMPORT MODULES              -- */
////////////////////////////////////////////////////

include { Demux } from '../subworkflows/demux'


////////////////////////////////////////////////////
/* --           RUN MAIN WORKFLOW              -- */
////////////////////////////////////////////////////

workflow Demux_Full {
    take:
        guppy_dir
        ont_metadata
    
    main:

        Demux(
            guppy_dir,
            ont_metadata
        )
        
    emit:
        Demux.out
} 

