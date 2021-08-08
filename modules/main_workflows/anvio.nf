#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

////////////////////////////////////////////////////
/* --              Parameter setup             -- */
////////////////////////////////////////////////////

////////////////////////////////////////////////////
/* --              IMPORT MODULES              -- */
////////////////////////////////////////////////////

include { make_cogs } from '../tools/anvio/anvio'
include { make_genome_db } from '../tools/anvio/anvio'
include { annotate_cogs } from '../tools/anvio/anvio'
include { combine } from '../tools/anvio/anvio'
include { pangenome } from '../tools/anvio/anvio'
include { summarize } from '../tools/anvio/anvio'

////////////////////////////////////////////////////
/* --           RUN MAIN WORKFLOW              -- */
////////////////////////////////////////////////////

workflow Anvio {
    take:
        assemblies_in
    main:
        make_cogs()

        make_genome_db(
            assemblies_in
        )

        annotate_cogs(
            make_genome_db.out.db,
            make_cogs.out.cog_index.collect()
        )

        combine(
            annotate_cogs.out.db_cog
            annotate_cogs.out.db_txt.collect()
        )

        pangenome(
            combine.out.combined
        )

        summarize(
            pangenome.out.pan_db
            combine.out.combined
        )

    emit:
        pangenome.out.pan_db

}