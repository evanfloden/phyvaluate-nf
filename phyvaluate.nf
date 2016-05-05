/* 
 * Main phyvaluate-NF pipeline script
 *
 * @authors
 * Evan Floden <evanfloden@gmail.com> 
 */


params.name          = "Evaluation of Phylogenetic Trees from Simulated Data"
params.input         = "$baseDir/tutorial/data/*.fa"
params.ref_trees     = "$baseDir/tutorial/data/*.tt"
params.output        = "$baseDir/tutorial/results"
params.aligner       = "MEGA-Coffee"


log.info "c o n c T r e e  - N F  ~  version 0.1"
log.info "====================================="
log.info "name                   : ${params.name}"
log.info "input                  : ${params.input}"
log.info "ref_trees              : ${params.ref_trees}"
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
    .into {fastas_1; fastas_2}


ref_trees = Channel
    .fromPath( params.ref_trees )
    .ifEmpty { error "Cannot find any input sequence files matching: ${params.ref_trees}" }
    .map { file -> tuple( file.baseName, file ) }


process align {
    publishDir "$results_path/$aligner/$datasetID/align", mode: 'copy', overwrite: 'true'
 
    input:
    set val(datasetID), file(fasta) from fastas_2
    
    output:
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


process alignUPP {

  input:
      set val(datasetID), file(fasta) from fastas_1

  output:
      set val(datasetID), file("${datasetID}_upp.nwk") into upp_trees
  
  script:
  """
      run_upp.py -s ${fasta} -m amino --cpu ${task.cpus} -d ${datasetID} -o ${datasetID}_upp.aln
      cp ${datasetID}/pasta.fasttree ${datasetID}_upp.nwk
  """
}


process compare_tree {
    publishDir "$results_path/$aligner/$datasetID/compare", mode: 'copy', overwrite: 'true'

    input:
    set val(datasetID), file(predicted_tree) from predicted_trees
    set val(datasetID), file(predicted_upp_tree) from upp_trees
    set val(datasetID), file(ref_tree) from ref_trees

    output:
    set val(datasetID), file('compareTree_${datasetID}_mega.txt'), file ('compareTree_${datasetID}_upp.txt')
    file (result.txt) into result_txts

    script:
    //
    // Compare the Reference Tree to the Aligner Tree
    //
    """
        CompareTree.pl -tree ${predicted_tree} \
                       -versus ${ref_tree} > 'compareTree_${datasetID}_mega.txt'
 
        CompareTree.pl -tree ${predicted_upp_tree} \
                       -versus ${ref_tree} > 'compareTree_${datasetID}_upp.txt'

        mega=\$(cat compareTree_${datasetID}_mega.txt)
        upp=\$(cat compareTree_${datasetID}_upp.txt)

        regex="frac\t([0-9]+.[0-9]+)"

        [[ \$mega =~ \$regex ]]
        RF_mega="\${BASH_REMATCH[1]}"

        [[ \$upp  =~ \$regex ]]
        RF_upp="{BASH_REMATCH[1]}"

        echo "\$RF_mega\t\$RF_upp" > result.txt

    """
}

result_txts.collectFile(storeDir: "$results_path/final") { item -> [ "RF_results.txt", item.text ] }

