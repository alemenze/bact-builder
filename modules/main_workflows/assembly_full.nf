#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

////////////////////////////////////////////////////
/* --              Parameter setup             -- */
////////////////////////////////////////////////////

////////////////////////////////////////////////////
/* --              IMPORT MODULES              -- */
////////////////////////////////////////////////////

include { Assemblies } from '../subworkflows/assemblies'
include { Assemblies as Assemblies_rep2 } from '../subworkflows/assemblies'
include { Assemblies as Assemblies_rep3 } from '../subworkflows/assemblies'

////////////////////////////////////////////////////
/* --           RUN MAIN WORKFLOW              -- */
////////////////////////////////////////////////////

workflow Assembly_Full {
    take:
        sample_reads
    main:

        Assemblies(
            sample_reads,
            'Replicate1'
        )

        Assemblies_rep2(
            sample_reads,
            'Replicate2'
        )

        Assemblies_rep3(
            sample_reads,
            'Replicate3'
        )

        assemblies_collection=Assemblies.out.assemblies
            .mix(Assemblies_rep2.out.assemblies, Assemblies_rep3.out.assemblies)
            .groupTuple(by:0)
            .map{ it -> tuple(it[0], it[1]+it[2]+it[3]+it[4])}//Merges the 4 types of assemblies out

    emit:
        assemblies_collection
}

