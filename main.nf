#!/usr/bin/env nextflow
/*
                              (╯°□°)╯︵ ┻━┻

========================================================================================
                Workflow for assembling bacterial de novo genomes
                With multiple layers of assembly and consensus
========================================================================================
                  https://github.com/alemenze/bact-builder
*/

nextflow.enable.dsl = 2

def helpMessage(){
    log.info"""

    Usage:
    
        nextflow run alemenze/bact-builder \
        --samplesheet ./metadata.csv
        -profile singularity

    Mandatory for full workflow:
        --samplesheet               CSV file with information on the samples (see example)
        -profile                    Currently available for docker (local), singularity (HPC local), slurm (HPC multi node) and GCP (requires credentials)
    
    Guppy parameters:
        --flowcell                  Flowcell type for guppy demux. Defaults to 'FLO-MIN106'
        --kit                       ONT kit for guppy demux. Defaults to 'SQK-LSK109'
        --barcode_kit               Barcode kit used for multiplexing with ONT. Defaults to 'EXP-NBD104 EXP-NBD114'
        --gpu_active                Default: false. Activates use of GPUs
        --gpus                      Number of GPUs to use. Requires GPUs to use. Defaults to 0
        --cpus                      Number of CPUs to use. Defaults to 2
        --threads                   Number of threads per CPU to use. Defaults to 20

    Kraken QC:
        --kraken_db                 Default: Standard DB from https://genome-idx.s3://genome-idx/kraken/k2_standard_20201202.tar.gz that can be found https://benlangmead.github.io/aws-indexes/k2
        --kraken_tax_level          Default: S. Options Include D, K, P, C, O, F, G, S for respective taxonomic rank

    Filtering parameters:
        --min_length                Minimum length of reads for filtlong. Defaults to 1000.
        --min_mean_q                Minimum quality score for bases for filtlong. Defaults to 70.
        --genome_size_bytes         Putative (or known) genome size for filtering in bytes. Defaults to 4400000

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

    Anvio parameters:
        --anvio_run                 Defaults to false. If true, it will run Anvio. 
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

    Slurm Controller:
        --node_partition            Specify the node partition in use for slurm executor. Defaults to 'main' 
        --gpu_node_partition        Specify the node for GPU access. Defaults to 'gpu'
        --gpu_clusterOptions        Specify GPU node options. Defaults to "--gres=gpu:1 --constraint=pascal" for dev cluster constraints. 

    GCP Options:
        --google_bucket             <gs://bucket/subfolder/> to stage running files. 
        --google_preemptible        Defaults to false. You can change this to true to get better cost savings, but nodes can be taken

    Workflow control:
        --skip_demux                Defaults to false. If true, it will skip the demultiplexing step. This requires a different input metadata sheet (see examples).
        --only_demux                Defaults to false. If true, it will only do the demultiplexing. This requires a truncated input metadata sheet (see examples). 
        --only_assembly             Defaults to false. If true, it will only run the assembly steps. This is often used for those who need manual trycycler steps, and will require a different metadata sheet (see examples) 
        --only_polish               Defaults to false. If true, it will only run the polishing steps. This requires a different input metadata sheet (see examples).
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

//Full Workflow Params
if (!params.skip_demux && !params.only_demux && !params.only_assembly && !params.only_clustering && !params.demux_assembly){
    Channel
        .fromPath(params.samplesheet)
        .splitCsv(header:true)
        .map{ row -> tuple(row.fast5_dir)}
        .unique()
        .set { guppy_dirs }

    Channel
        .fromPath(params.samplesheet)
        .splitCsv(header:true)
        .map{ row -> tuple(row.fast5_dirname, row.ont_barcode, row.sample_id)}
        .set { ont_metadata }

    Channel
        .fromPath(params.samplesheet)
        .splitCsv(header:true)
        .map{ row -> tuple(row.sample_id, file(row.illumina_r1), file(row.illumina_r2))}
        .set { illumina_metadata }
}

//Skip Demux
if (params.skip_demux){
    Channel
        .fromPath(params.samplesheet)
        .splitCsv(header:true)
        .map{ row -> tuple(row.sample_id, row.ont_fastq)}
        .set { ont_metadata }

    Channel
        .fromPath(params.samplesheet)
        .splitCsv(header:true)
        .map{ row -> tuple(row.sample_id, file(row.illumina_r1), file(row.illumina_r2))}
        .set { illumina_metadata }
}

//Only Demux
if (params.only_demux){
    Channel
        .fromPath(params.samplesheet)
        .splitCsv(header:true)
        .map{ row -> tuple(row.fast5_dir)}
        .unique()
        .set { guppy_dirs }

    Channel
        .fromPath(params.samplesheet)
        .splitCsv(header:true)
        .map{ row -> tuple(row.fast5_dirname, row.ont_barcode, row.sample_id)}
        .set { ont_metadata }
}

//Only Assembly
if (params.only_assembly){
    Channel
        .fromPath(params.samplesheet)
        .splitCsv(header:true)
        .map{ row -> tuple(row.sample_id, row.ont_fastq)}
        .set { ont_metadata }
}

//Only Polish
if (params.only_polish){
    Channel
        .fromPath(params.samplesheet)
        .splitCsv(header:true)
        .map{ row -> tuple(row.sample_id, row.ont_fastq)}
        .set { ont_metadata }

    Channel
        .fromPath(params.samplesheet)
        .splitCsv(header:true)
        .map{ row -> tuple(row.sample_id, file(row.illumina_r1), file(row.illumina_r2))}
        .set { illumina_metadata }
}


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

workflow {
    //Full Workflow
    if (!params.skip_demux && !params.only_demux){
        Demux_Full(
            guppy_dirs,
            ont_metadata
        )

        Kraken(
            Demux_Full.out,
            'Kraken'
        )

        Assembly_Full(
            Demux_Full.out
        )

        Assembly_Full.out.map{ it -> tuple( it[0], it[1].collect())}
                .set{trycycler_input}

        ch_trycycler = Demux_Full.out.join(Assembly_Full.out, by: [0]) //Should be ID, ONT fastqs, assemblies

        Trycycler_Full(
            ch_trycycler
        )

        ch_polishing = Trycycler_Full.out
            .join(Demux_Full.out, by:0) //And now should be ID, ONT consensus, ONT reads

        Polish(
            ch_polishing,
            illumina_metadata
        )
        if(params.anvio_run){
            Anvio(
                Polish.out
            )
        }
        
    }

    //Skip Demux
    if (params.skip_demux){
        Assembly_Full(
            ont_metadata
        )

        Assembly_Full.out.map{ it -> tuple( it[0], it[1].collect())}
                .set{trycycler_input}

        ch_trycycler = ont_metadata(Assembly_Full.out, by: [0]) //Should be ID, ONT fastqs, assemblies

        Trycycler_Full(
            ch_trycycler
        )

        ch_polishing = Trycycler_Full.out
            .join(ont_metadata, by:0) //And now should be ID, ONT consensus, ONT reads

        Polish(
            ch_polishing,
            illumina_metadata
        )

        if(params.anvio_run){
            Anvio(
                Polish.out
            )
        }
    }

    //Only Demux
    if (params.only_demux){
        Demux_Full(
            guppy_dirs,
            ont_metadata
        )

        Kraken(
            Demux_Full.out,
            'Kraken'
        )
    }

    //Only Assembly
    if (params.only_assembly){
        Assembly_Full(
            ont_metadata
        )
    }

    //Only Polish
    if (params.only_polish){
        Polish(
            ont_metadata,
            illumina_metadata
        )
    }
}