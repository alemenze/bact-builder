#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl = 2

// Process definition
process guppy_basecaller {
    tag "${reads}"
    
    publishDir "${params.outdir}/guppy",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    if (params.gpu_active){
        container 'genomicpariscentre/guppy-gpu:4.2.2'
    } else {
        container 'genomicpariscentre/guppy:4.2.2'
    }

    input:
        path(reads)

    output:
        path("fastq/*.fastq.gz"), emit: fastq
        path "*.log", emit: log
        path "*.txt", emit: sequencing_summary
        path "*.js", emit: telemetry

    script:
        flowcell=params.flowcell ? "--flowcell $params.flowcell --kit $params.kit": ""
        barcode_kit=params.barcode_kit ? "--barcode_kits '$params.barcode_kit'": ""
        cpu_opts=params.cpus ? "--num_callers $params.cpus --cpu_threads_per_caller $params.threads": ""
        if (params.gpu_active){
            gpu_opts = "--gpu_runners_per_device $params.gpus -x cuda:all:100% "
        } else {
            gpu_opts = ""
        }
        """
        guppy_basecaller --input_path $reads \\
            --save_path . \\
            --records_per_fastq 0 \\
            --compress_fastq \\
            $flowcell \\
            $barcode_kit \\
            $cpu_opts \\
            $gpu_opts
            
        # have to combine fastqs
        mkdir fastq
        if [ "\$(find . -type d -name "barcode*" )" != "" ]
        then
            for dir in barcode*/
            do
                dir=\${dir%*/}
                cat \$dir/*.fastq.gz > ./fastq/\$dir.fastq.gz
            done
        else
            cat *.fastq.gz > ./fastq/output.fastq.gz
        fi
        """
}

