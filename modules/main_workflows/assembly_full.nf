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

        temp_assemblies=Channel.empty()
        temp_assemblies=Assemblies.out.assemblies.join(Assemblies_rep2.out.assemblies)
        assemblies=Channel.empty()
        assemblies=temp_assemblies.join(Assemblies_rep3.out.assemblies)

        assemblies.map{ it -> tuple( it[0], it[1].collect())}
            .set{assemblies_collection}

    emit:
        assemblies_collection
}

