#!/usr/bin/env nextflow
/*
                              (╯°□°)╯︵ ┻━┻

========================================================================================
                WORKFLOW
========================================================================================
                  https://github.com/alemenze/####
*/

nextflow.enable.dsl = 2

def helpMessage(){
    log.info"""

    Usage:
    
        nextflow run alemenze/#### \

        -profile singularity

    Mandatory for full workflow:
        --input_dir                 Path to directory of .FAST5 files off the ONT device
        
        -profile                    Currently available for docker (local), singularity (HPC local), slurm (HPC multi node) and GCP (requires credentials)
    
    Guppy parameters:
        --flowcell                  Flowcell type for guppy demux. Defaults to 'FLO-MIN106'
        --kit                       ONT kit for guppy demux. Defaults to 'SQK-LSK109'
        --barcode_kit               Barcode kit used for multiplexing with ONT. Defaults to 'EXP-NBD104 EXP-NBD114'
        --gpu_active                Default: False. Activates use of GPUs
        --gpus                      Number of GPUs to use. Requires GPUs to use. Defaults to 0
        --cpus                      Number of CPUs to use. Defaults to 2
        --threads                   Number of threads per CPU to use. Defaults to 20

    Kraken QC:
        --kraken_db                 Default: Standard DB from https://genome-idx.s3://genome-idx/kraken/k2_standard_20201202.tar.gz that can be found https://benlangmead.github.io/aws-indexes/k2
        --kraken_tax_level          Default: S. Options Include D, K, P, C, O, F, G, S for respective taxonomic rank

    Assembly parameters:
        --subset_cov                Depth to randomly subset to, integer value (IE 100 for 100X). Defaults to 100
        --genome_size               Putative (or known) genome size of organism of assembly. Defaults to 4.4mb
        --assembly_genome_size      Putative (or known) genome size of organism for assembly. Defaults to 5m

    General Trycycler parameters:
        --min_contig_depth          Default: 0.5. Trycycler default is 0.1
        --max_length_diff           Default: 1.3. This will allow a bit of flexibility for the automation. Trycycler default is 1.1
        --min_identity              Default: 95. Again, for a bit of flexibility in the automation. Trycycler default is 95
        --max_add_seq               Default: 10000. Trycycler default is 1000.
        --max_indel_size            Default: 1000. Trycycler default is 250.

    Anvio paramteres:
        --project_name              Default: 'ProjectName'. Doesnt effect procesing, more for personalizations
        --min_occurence             Default: 1. Increasing will speed things up, but will exclude genes that occur in <X genomes
        --minbit                    Default: 0.5. Closer to 1 focuses on longer amino acids that are very similar, closer to 0 will focus on shorter amino acids that may match
        --distance                  Default: euclidean. 
        --linkage                   Default: ward
        --mcl                       Default: 10. Define sensitivity. 1 works for very distanced genomes, 10 for super related ones
        --bin_name                  Default: 'EVERYTHING'. Doesnt effect procesing, more for personalizations or more customized tweaks downstream
        --collection_name           Default: 'Default'. Doesnt effect procesing, more for personalizations or more customized tweaks downstream


    Optional:
        --outdir                    Directory for output directories/files. Defaults to './results' 
        --node_partition            Specify the node partition in use for slurm executor. Defaults to 'main' 

    GCP Options:
        --google_bucket             <gs://bucket/subfolder/> to stage running files. 
        --google_preemptible        Defaults to false. You can change this to true to get better cost savings, but nodes can be taken
        
    """

}

// Show help message
if (params.help) {
    helpMessage()
    exit 0
}


////////////////////////////////////////////////////
/* --              Parameter setup             -- */
////////////////////////////////////////////////////
if (params.samplesheet) {file(params.samplesheet, checkIfExists: true)} else { exit 1, 'Samplesheet file not specified!'}

Channel
    .fromPath(params.samplesheet)
    .splitCsv(header:true)
    .map{ row -> tuple(row.fast5_dir)}
    .unique()
    .set { guppy_dirs }

Channel
    .fromPath(params.samplesheet)
    .splitCsv(header:true)
    .map{ row -> tuple(row.fast5_dir, row.barcode, row.sample_id)}
    .set { ont_metadata }

Channel
    .fromPath(params.samplesheet)
    .splitCsv(header:true)
    .map{ row -> tuple(row.sample_id, file(row.illumina_r1), file(row.illumina_r2))}
    .set { illumina_metadata }


////////////////////////////////////////////////////
/* --              IMPORT MODULES              -- */
////////////////////////////////////////////////////
include { Demux_Full } from './modules/main_workflows/demux_full'
include { Assembly_Full } from './modules/main_workflows/assembly_full'
include { Trycycler_Full } from './modules/main_workflows/trycycler'
include { Polish } from './modules/main_workflows/polish'
include { Anvio } from './modules/main_workflows/anvio'
include { Kraken } from './modules/subworkflows/kraken'

////////////////////////////////////////////////////
/* --           RUN MAIN WORKFLOW              -- */
////////////////////////////////////////////////////

// Full workflow demultiplexing through Trycycler
workflow {
    Demux_Full(
        guppy_dirs
    )

    ch_demuxed = ont_metadata.join(Demux_Full.out, by: [0,1])
    ch_demuxed_filtered = ch_demuxed
        .filter({ guppy, bc, id, reads -> reads.size() > params.genome_size_bytes*95}) //Each tuple should start as guppy_dir, barcode, sample_id, reads
        .map{ it -> tuple(it[2], it[3]) } //And end as id, reads


    Kraken(
        ch_demuxed_filtered,
        'Kraken'
    )

    Assembly_Full(
        ch_demuxed_filtered
    )

    Assembly_Full.out.map{ it -> tuple( it[0], it[1].collect())}
            .set{trycycler_input}

    ch_trycycler = ch_demuxed_filtered.join(Assembly_Full.out, by: [0]) //Should be ID, ONT fastqs, assemblies

    Trycycler_Full(
        ch_trycycler
    )

    ch_polishing = Trycycler_Full.out
        .join(ch_demuxed_filtered, by:0) //And now should be ID, ONT consensus, ONT reads

    Polish(
        ch_polishing,
        illumina_metadata
    )

    //Anvio(
    //    Polish.out
    //)
}