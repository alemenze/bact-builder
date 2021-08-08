#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl = 2

// Process definition
process Kraken2 {
    tag "${reads}"
    label 'process_medium'

    publishDir "${params.outdir}/kraken2/${meta}",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "alemenze/kraken2-docker"

    input:
        tuple val(meta), path(reads)
        path(db)
        val(read_type)

    output:
        tuple val(meta), path("*kraken2.krona"), emit: kraken2krona
        path("*_kraken2.report")
        path("*_bracken.tsv")

    script:
        if (read_type=='single') {
            input="$reads"
            read_len='250'
        }
        if (read_type=='paired') {
            input="--paired ${reads[0]} ${reads[1]}"
            read_len='150'
        }
        """
        kraken2 -db $db --report ${meta}_kraken2.report $input > ${meta}_kraken2.output
        cut -f 2,3 ${meta}_kraken2.output > ${meta}_kraken2.krona

        bracken -d $db -r $read_len -i ${meta}_kraken2.report -l $params.kraken_tax_level -o ${meta}_bracken.tsv
        """
}

process Kraken2_db_build {

    container "alemenze/kraken2-docker"

    input:
        path(kraken)
        val(kraken_name)

    output:
        path("./${kraken_name}/", type:'dir', emit: kraken2_ch)
    
    script:
        """
        mkdir -p $kraken_name && tar -xvzf $kraken -C $kraken_name
        """
}

process Krona {

    container "alemenze/kraken2-docker"

    publishDir "${params.outdir}/kraken2_krona/${meta}",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }
    
    input:
        tuple val(meta), path(krona_in)
    
    output:
        path("*_taxonomy_krona.html")

    script:
        """
        ktImportTaxonomy -o ${meta}_kraken2_taxonomy_krona.html $krona_in
        """
}