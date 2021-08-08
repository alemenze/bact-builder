#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

////////////////////////////////////////////////////
/* --           Load Modules                  -- */
////////////////////////////////////////////////////

include {random_subset} from '../tools/rasusa/rasusa'
include {canu_assembly} from '../tools/canu/canu'
include {flye_assembly} from '../tools/flye/flye'
include {miniasm_assembly} from '../tools/miniasm/miniasm'
include {raven_assembly} from '../tools/raven/raven'
include {quast as canu_quast} from '../tools/quast/quast'
include {quast as flye_quast} from '../tools/quast/quast'
include {quast as miniasm_quast} from '../tools/quast/quast'
include {quast as raven_quast} from '../tools/quast/quast'

////////////////////////////////////////////////////
/* --           RUN MAIN WORKFLOW              -- */
////////////////////////////////////////////////////

workflow Assemblies {
    take:
        reads
        replicate_num
    main:
        random_subset(
            reads,
            replicate_num
        )
        canu_assembly(
            random_subset.out.fastq,
            replicate_num
        )
        canu_quast(
            canu_assembly.out.assembly,
            replicate_num,
            'canu'
        )
        flye_assembly(
            random_subset.out.fastq,
            replicate_num
        )
        flye_quast(
            flye_assembly.out.assembly,
            replicate_num,
            'flye'
        )
        miniasm_assembly(
            random_subset.out.fastq,
            replicate_num
        )
        miniasm_quast(
            miniasm_assembly.out.assembly,
            replicate_num,
            'miniasm'
        )
        raven_assembly(
            random_subset.out.fastq,
            replicate_num
        )
        raven_quast(
            raven_assembly.out.assembly,
            replicate_num,
            'raven'
        )
        temp_assemblies=Channel.empty()
        temp_assemblies=canu_assembly.out.assembly.join(flye_assembly.out.assembly)
        temp2_assemblies=Channel.empty()
        temp2_assemblies=temp_assemblies.join(raven_assembly.out.assembly)
        assemblies=Channel.empty()
        assemblies=temp2_assemblies.join(miniasm_assembly.out.assembly)

    emit:
        assemblies
}