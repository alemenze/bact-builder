#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl = 2

// Process definition
process pycoqc {
    tag "${sequencing_summary}"
    label 'process_low'

    publishDir "${params.outdir}/pycoqc/${run}/${type}",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "quay.io/biocontainers/pycoqc:2.5.0.23--py_0"

    input:
        tuple path(sequencing_summary), val(run)
        val(type)

    output:
        path '*.html', emit: report

    script:    
        """
        pycoQC --summary_file $sequencing_summary --html_outfile pycoqc_report.html
        """
}