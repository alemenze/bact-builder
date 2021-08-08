#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

////////////////////////////////////////////////////
/* --              Parameter setup             -- */
////////////////////////////////////////////////////

////////////////////////////////////////////////////
/* --              IMPORT MODULES              -- */
////////////////////////////////////////////////////

include { trycycler_cluster } from '../tools/trycycler/trycycler'
include { trycycler_reconcile } from '../tools/trycycler/trycycler'
include { trycycler_msa } from '../tools/trycycler/trycycler'
include { trycycler_partition } from '../tools/trycycler/trycycler'
include { trycycler_consensus } from '../tools/trycycler/trycycler'

////////////////////////////////////////////////////
/* --           RUN MAIN WORKFLOW              -- */
////////////////////////////////////////////////////

workflow Trycycler_Full {
    take:
        trycycler_input

    main:
        trycycler_cluster(
            trycycler_input
        )

        trycycler_cluster.out.cluster_dirs
            .map{ it ->
                tuple( it[0], it[1].collate(1))
            }
            .transpose()
            .join(trycycler_input, by: [0])
            .map{ it -> tuple(it[0], it[1]), it[3] }
            .set{reconcile_in}
            
        trycycler_reconcile(
            reconcile_in
        )

        trycycler_reconcile.out.cluster_dirs
            .map{ it ->
                tuple( it[0], it[1].collate(1))
            }
            .transpose()
            .set{msa_in}

        trycycler_msa(msa_in)

        trycycler_msa.out.cluster_dirs
            .map{ it ->
                tuple( it[0], it[1].collate(1))
            }
            .transpose()
            .join(trycycler_input, by: [0])
            .map{ it -> tuple(it[0], it[1]), it[3] }
            .set{partition_in}

        trycycler_partition(partition_in)

        trycycler_partition.out.cluster_dirs
            .map{ it ->
                tuple( it[0], it[1].collate(1))
            }
            .transpose()
            .set{consensus_in}

        trycycler_consensus(consensus_in)

    emit:
        trycycler_consensus.out.consensus

}