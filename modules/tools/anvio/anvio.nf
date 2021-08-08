#!/usr/bin/env nextflow

// Specify DSL2
nextflow.enable.dsl=2

// Process definition
process make_cogs{
    tag "${meta}"
    label 'process_medium'

    container "meren/anvio:7"

    output:
        path("cog_dir.tar"), emit: cog_index
    
    //Great solution to a sticky issue here from the FredHutch Anvio PanGenome workflow
    script:
        """
        anvi-setup-ncbi-cogs --num-threads ${task.cpus} --cog-data-dir cog_dir --just-do-it --reset
        tar cvf cog_dir.tar cog_dir
        """
}

process make_genome_db{
    tag "${meta}"
    label 'process_low'

    publishDir "${params.outdir}/anvio/dbs/${meta}",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "meren/anvio:7"

    input:
        tuple val(meta), path(assembly)
    
    output:
        tuple val(meta), path("*.db"), emit: db
    
    script:
        """
        anvi-gen-contigs-database -f $assembly -n ${meta} -o ${meta}.db
        """
}

process annotate_cogs{
    tag "${meta}"
    label 'process_medium'

    publishDir "${params.outdir}/anvio/db_cogs/${meta}",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "meren/anvio:7"

    input:
        tuple val(meta), path(db)
        path(cogs)

    output:
        tuple val(meta), path("*.db"), emit: db_cog
        path('*.txt'), emit: db_txt
    
    script:
        """
        tar xvf $cogs
        anvi-run-ncbi-cogs -c $db --num-threads ${task.cpus} --cog-data-dir cog_dir
        echo -e ${meta},${meta}.db | tr ',' '\\t' > ${meta}.txt
        """
}

process combine{
    label 'process_medium'

    publishDir "${params.outdir}/anvio/db_combine/",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "meren/anvio:7"

    input:
        tuple val(meta), path(db)
        path db_txt
    
    output:
        path('SAMPLES-GENOMES.db'), emit: combined
        path('external_genomes.txt'), emit: external
        
    script:
        """
        echo -e "name\\tcontigs_db_path" > external-genomes.txt
        for txt in $db_txt; do cat \$txt; done >> external_genomes.txt
        anvi-gen-genomes-storage -e external-genomes -o SAMPLES-GENOMES.db
        """
}

process pangenome{
    label 'process_high'

    publishDir "${params.outdir}/anvio/pangenome/",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "meren/anvio:7"

    input:
        path(combined)
    
    output:
        path('*-PAN.db'), emit: pan_db
        
    script:
        """
        anvi-pan-genome -g $combined \
            --project-name $params.project_name \
            --output-dir ./ \
            --num-threads ${task.cpus} \
            --use-ncbi-blast \
            --min-occurence $params.min_occurence \
            --minbit $params.minbit \
            --distance $params.distance \
            --linkage $params.linkage \
            --mcl-inflation $params.mcl
        """
}

process summarize{
    label 'process_medium'

    publishDir "${params.outdir}/anvio/pangenome/",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    container "meren/anvio:7"

    input:
        path(pan_db)
        path(combined)

    output:
        path("PROJECT_SUMMARY"), emit: summary

    script:
        """
        anvi-script-add-default-collection \
            -p $pan_db \
            -c $combined \
            -b $params.bin_name \
            -C $params.collection_name 

        anvi-summarize -p $pan_db \
            -g $combined \
            -C $params.collection_name \
            -o PROJECT_SUMMARY
        """
}

