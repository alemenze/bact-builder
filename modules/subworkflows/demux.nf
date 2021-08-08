#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

////////////////////////////////////////////////////
/* --              Parameter setup             -- */
////////////////////////////////////////////////////


if (!params.flowcell) {exit 1, 'No flowcell type specified!'}
if (!params.kit) {exit 1, 'No Kit type specified!'}

////////////////////////////////////////////////////
/* --           Load Modules                  -- */
////////////////////////////////////////////////////

include {guppy_basecaller} from '../tools/guppy/guppy'
include {nanoplot} from '../tools/nanoplot/nanoplot'
include {pycoqc} from '../tools/pycoqc/pycoqc'
include {fastp} from '../tools/fastp/fastp'
include {fastp as fastp_trimmed} from '../tools/fastp/fastp'
include {filtlong} from '../tools/filtlong/filtlong'

////////////////////////////////////////////////////
/* --           RUN MAIN WORKFLOW              -- */
////////////////////////////////////////////////////


workflow Demux {
  take:
    ch_input_dir

  main:
    guppy_basecaller(
      ch_input_dir
    )
    pycoqc(
      guppy_basecaller.out.sequencing_summary,
      'guppy_qc'
    )
    ch_ont_fastq = Channel.empty()
    ch_ont_fastq = guppy_basecaller.out.fastq
      .map { it -> tuple(it[0].baseName, it[0], it[1]) }
    fastp(
      ch_ont_fastq,
      'guppy_qc'
    )
    nanoplot(
      ch_ont_fastq,
      'guppy_qc'
    )
    filtlong(
      ch_ont_fastq
    )
    fastp_trimmed(
      filtlong.out.fastq,
      'filtlong'
    )
    trimmed_fastq = Channel.empty()
    trimmed_fastq=filtlong.out.fastq
  
  emit:
    reads=trimmed_fastq
    
}