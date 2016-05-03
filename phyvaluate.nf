/* 
 * Main phyvaluate-NF pipeline script
 *
 * @authors
 * Evan Floden <evanfloden@gmail.com> 
 */


params.name          = "Evaluation of Phylogenetic Trees from Simulated Data"
params.input         = "$baseDir/tutorial/data/*.fa"
params.ref_trees     = "$baseDir/tutorial/data/*.nwk"
params.output        = "$baseDir/tutorial/results"
params.aligner       = "MEGA-Coffee"


log.info "c o n c T r e e  - N F  ~  version 0.1"
log.info "====================================="
log.info "name                   : ${params.name}"
log.info "input                  : ${params.input}"
log.info "ref_trees              : ${params.ref_tree}"
log.info "output                 : ${params.output}"
log.info "aligner                : ${params.aligner}"
log.info "\n"


/*
 * Input parameters validation
 */

results_path            = file(params.output)
aligner                 = params.aligner

/*
 * Create a channel for input sequence files 
 */
 
fastas = Channel
    .fromPath( params.input )
    .ifEmpty { error "Cannot find any input sequence files matching: ${params.input}" }
    .map { file -> tuple( file.baseName, file ) }

ref_trees = Channel
    .fromPath( params.ref_trees )
    .ifEmpty { error "Cannot find any input sequence files matching: ${params.ref_tree}" }
    .map { file -> tuple( file.baseName, file ) }


process align {
    publishDir "$results_path/$aligner/$datasetID/align", mode: 'copy', overwrite: 'true'
 
    input:
    set val(datasetID), file(fasta) from fastas
    
    output:
    set val(datasetID), file("${datasetID}_prediction.aln") into predicted_alignments
    set val(datasetID), file("${datasetID}_prediction.nwk") into predicted_trees

    script:
    //
    // Align each dataset with aligner
    // 
    """
        mega_coffee -i ${fasta} \
                    -o "${datasetID}_prediction.aln" \
                    --cluster_size 2 \
                    --cluster_number 5000 \
                    -n ${task.cpus} \
                    --phylo_out "${datasetID}_prediction.nwk" \
                    -d
    """
}

process compare_tree {
    publishDir "$results_path/$aligner/$datasetID/compare", mode: 'copy', overwrite: 'true'

    input:
    set val(datasetID), file(predicted_tree) from predicted_trees
    set val(datasetID), file(ref_tree) from ref_trees

    output:

    script:
    //
    // Compare the Reference Tree to the Aligner Tree
    //
    """
        CompareTree.pl -tree ${predicted_tree} \
                       -versus ${ref_tree}  
    """
}
