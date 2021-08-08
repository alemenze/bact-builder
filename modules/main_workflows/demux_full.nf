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
    
    main:

        Demux(
            guppy_dir
        )
        
        demuxed_reads=Channel.empty()
        demuxed_reads=guppy_dir
            .combine(Demux.out.reads)

    emit:
        demuxed_reads
} 

