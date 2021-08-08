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
    ont_metadata

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
      .flatten()
      .map { it -> tuple(it.baseName.substring(0, it.baseName.lastIndexOf('_')),it.baseName.substring(it.baseName.lastIndexOf('_'),it.baseName.lastIndexOf('.')), it) } //dir,bc,sample

    ch_demuxed = ont_metadata.join(ch_ont_fastq, by: [0,1])//dir,bc,id with dir, bc, sample to become dir, bc, id, sample. 
    ch_demuxed_filtered = ch_demuxed
        .filter({ guppy, bc, id, reads -> reads.size() > params.genome_size_bytes*95}) //Each tuple should start as guppy_dir, barcode, sample_id, reads
        .map{ it -> tuple(it[2], it[3]) } //And end as id, reads

    fastp(
      ch_demuxed_filtered,
      'guppy_qc'
    )
    nanoplot(
      ch_demuxed_filtered,
      'guppy_qc'
    )
    filtlong(
      ch_demuxed_filtered
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