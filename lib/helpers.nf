def helpMessage() {
  // TODO: fill out help message
  log.info"""
  TODO: incomplete help message
  ==================================================================
  ${workflow.manifest.name}  ~  version ${workflow.manifest.version}
  ==================================================================

  Git info: $workflow.repository - $workflow.revision [$workflow.commitId]

  Workflow for benchmarking and generating genotyping results for Salmonella Typhi genomes with:
  - biohansel
  - genotyphi
  - SKA
  and benchmarking and generating genotyping results for Mycobacterium tuberculosis with:
  - biohansel
  - SKA

  Usage:
  The typical command for running the pipeline is as follows:
  
  \$ nextflow run peterk87/nf-bh-typing-comparison \\
       -profile conda \\
       --typhi_input "typhi/*.fasta" \\
       --mtb_input "mtb/*.fasta" \\
       --outdir results
  
  Required Options:
    --typhi_input                 Input Salmonella Typhi FASTA files
    --mtb_input                   Input M. tuberculosis FASTA files

  ART Options:
    --art_seq_sys                 ART Illumina sequencing system (default: ${params.art_seq_sys})
    --art_read_length             ART mean read length (default: ${params.art_read_length})
    --art_mean_fragment_length    ART mean fragment length (default: ${params.art_mean_fragment_length})
    --art_fragment_length_sdev    ART fragment length standard deviation (default: ${params.art_fragment_length_sdev})
    --art_random_seed             ART random seed number (default: ${params.art_random_seed})

  Genotyphi Options:


  Other options:
    --outdir                      The output directory where the results will be saved (default: ${params.outdir})
    -w/--work-dir                 The temporary directory where intermediate data will be saved (default: ${workflow.workDir})
    -profile                      Configuration profile to use. [standard, other_profiles] (default: ${workflow.profile})
  """.stripIndent()
}