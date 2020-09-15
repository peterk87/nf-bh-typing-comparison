#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { helpMessage } from './lib/helpers'

// Show help message if --help specified
if (params.help){
  helpMessage()
  exit 0
}

//=============================================================================
// INPUT VALIDATION
//=============================================================================

if (workflow.profile == 'slurm' && params.slurm_queue == "") {
  exit 1, "You must specify a valid SLURM queue (e.g. '--slurm_queue <queue name>' (see `\$ sinfo` output for available queues)) to run this workflow with the 'slurm' profile!"
}

if (params.typhi_input == null && params.mtb_input == null) {
  exit 1, "You must specify input FASTA files via '--typhi_input' and/or '--mtb_input', otherwise, there's nothing to do!"
}

//=============================================================================
// WORKFLOW RUN PARAMETERS LOGGING
//=============================================================================

// Has the run name been specified by the user?
//  this has the bonus effect of catching both -name and --name
custom_runName = params.name
if( !(workflow.runName ==~ /[a-z]+_[a-z]+/) ){
  custom_runName = workflow.runName
}

// Header log info
log.info """=======================================================
${workflow.manifest.name} v${workflow.manifest.version}
======================================================="""
def summary = [:]
summary['Pipeline Name']    = workflow.manifest.name
summary['Pipeline Version'] = workflow.manifest.version
summary['Run Name']         = custom_runName ?: workflow.runName
summary['typhi_input'] = params.typhi_input
summary['mtb_input'] = params.mtb_input
summary['coverage'] = params.coverage
summary['typhi_ref_fasta'] = params.typhi_ref_fasta
summary['typhi_biohansel_scheme_fasta'] = params.typhi_biohansel_scheme_fasta
summary['typhi_biohansel_metadata_tsv'] = params.typhi_biohansel_metadata_tsv
summary['typhi_biohansel_mincov'] = params.typhi_biohansel_mincov
summary['typhi_ska_marker_fastas'] = params.typhi_ska_marker_fastas
summary['typhi_ska_profile'] = params.typhi_ska_profile
summary['mtb_biohansel_scheme_fasta'] = params.mtb_biohansel_scheme_fasta
summary['mtb_biohansel_metadata_tsv'] = params.mtb_biohansel_metadata_tsv
summary['mtb_biohansel_mincov'] = params.mtb_biohansel_mincov
summary['mtb_ska_marker_fastas'] = params.mtb_ska_marker_fastas
summary['mtb_ska_profile'] = params.mtb_ska_profile
summary['art_seq_sys'] = params.art_seq_sys
summary['art_min_qscore'] = params.art_min_qscore
summary['art_read_length'] = params.art_read_length
summary['art_mean_fragment_length'] = params.art_mean_fragment_length
summary['art_fragment_length_sdev'] = params.art_fragment_length_sdev
summary['art_random_seed'] = params.art_random_seed
summary['Max Memory']       = params.max_memory
summary['Max CPUs']         = params.max_cpus
summary['Max Time']         = params.max_time
summary['Container Engine'] = workflow.containerEngine
if(workflow.containerEngine) summary['Container'] = workflow.container
summary['Current home']   = "$HOME"
summary['Current user']   = "$USER"
summary['Current path']   = "$PWD"
summary['Working dir']    = workflow.workDir
summary['Output dir']     = file(params.outdir)
summary['Script dir']     = workflow.projectDir
summary['Config Profile'] = workflow.profile
if(workflow.profile == 'slurm') {
  summary['Slurm Queue'] = params.slurm_queue
  summary['Slurm Queue Size'] = params.slurm_queue_size
}
log.info summary.collect { k,v -> "${k.padRight(25)}: $v" }.join("\n")
log.info "========================================="

//=============================================================================
// PROCESSES
//=============================================================================
include {
  ART as ART_TYPHI;
  ART as ART_MTB 
  } from './process/art'
include {
  BIOHANSEL as BH_TYPHI;
  BIOHANSEL as BH_MTB
  } from './process/biohansel'
include {
  BOWTIE2_INDEX;
  GENOTYPHI_BOWTIE2;
  GENOTYPHI_BWAMEM2
  } from './process/genotyphi'
include { 
  SKA_SKETCH as SKA_SKETCH_TYPHI;
  SKA_SKETCH as SKA_SKETCH_MTB;
  SKA_TYPE_NO_PROFILE as SKA_TYPE_NO_PROFILE_TYPHI;
  SKA_TYPE_NO_PROFILE as SKA_TYPE_NO_PROFILE_MTB;
  SKA_TYPE_WITH_PROFILE as SKA_TYPE_WITH_PROFILE_TYPHI;
  SKA_TYPE_WITH_PROFILE as SKA_TYPE_WITH_PROFILE_MTB
  } from './process/ska'
include { TB_PROFILER } from './process/tb_profiler'
include { TRACE_TABLE } from './process/trace'

//=============================================================================
// MAIN WORKFLOW
//=============================================================================
workflow {
  main:
  ch_coverage = Channel.value(params.coverage)
  // S. Typhi (typhi) typing
  if (params.typhi_input) {
    // generate reads from input genome fastas
    ch_typhi_input = Channel.fromPath(params.typhi_input)
    ch_typhi_input | map { [it, 'typhi'] } | combine(ch_coverage) | ART_TYPHI

    Channel.fromPath(params.typhi_ref_fasta) | BOWTIE2_INDEX 
    // type with Genotyphi
    ART_TYPHI.out | combine( BOWTIE2_INDEX.out ) | GENOTYPHI_BOWTIE2
    // type with Genotyphi using BWA-MEM2 read mapping
    ART_TYPHI.out | combine(Channel.fromPath(params.typhi_ref_fasta)) | GENOTYPHI_BWAMEM2
    // type with biohansel
    ch_bh_scheme_metadata = Channel.fromPath(params.typhi_biohansel_scheme_fasta) \
        | combine(Channel.fromPath(params.typhi_biohansel_metadata_tsv))
    ART_TYPHI.out | combine(ch_bh_scheme_metadata) | BH_TYPHI
    ART_TYPHI.out | SKA_SKETCH_TYPHI
    // try to type with SKA
    ch_marker_fastas = Channel.value(file(params.typhi_ska_marker_fastas))
    SKA_TYPE_NO_PROFILE_TYPHI(SKA_SKETCH_TYPHI.out.results, ch_marker_fastas)
    ch_typhi_ska_profile = Channel.value(file(params.typhi_ska_profile))
    SKA_TYPE_WITH_PROFILE_TYPHI(SKA_SKETCH_TYPHI.out.results, ch_marker_fastas, ch_typhi_ska_profile)
  }
  // M. tuberculosis (mtb) typing 
  if (params.mtb_input) {
    // generate reads from input genome fastas
    ch_mtb_input = Channel.fromPath(params.mtb_input)
    ch_mtb_input | map { [it, 'mtb'] } | combine(ch_coverage) | ART_MTB
    // biohansel
    ch_bh_scheme_metadata_mtb = Channel.fromPath(params.mtb_biohansel_scheme_fasta) \
        | combine(Channel.fromPath(params.mtb_biohansel_metadata_tsv))
    ART_MTB.out | combine(ch_bh_scheme_metadata_mtb) | BH_MTB
    // SKA
    ART_MTB.out | SKA_SKETCH_MTB
    ch_marker_fastas_mtb = Channel.value(file(params.mtb_ska_marker_fastas))
    SKA_TYPE_NO_PROFILE_MTB(SKA_SKETCH_MTB.out.results, ch_marker_fastas_mtb)
    // tb-profiler
    ART_MTB.out | TB_PROFILER
  }
  if (params.typhi_input && params.mtb_input) {
    GENOTYPHI_BOWTIE2.out.trace
      .mix(
        GENOTYPHI_BWAMEM2.out.trace,
        SKA_SKETCH_TYPHI.out.trace,
        SKA_TYPE_WITH_PROFILE_TYPHI.out.trace,
        SKA_TYPE_NO_PROFILE_TYPHI.out.trace,
        BH_TYPHI.out.trace,
        BH_MTB.out.trace,
        SKA_SKETCH_MTB.out.trace,
        SKA_TYPE_NO_PROFILE_MTB.out.trace,
        TB_PROFILER.out.trace)
      .set { ch_trace }
  } else if (params.typhi_input && !params.mtb_input) {
    GENOTYPHI_BOWTIE2.out.trace
      .mix(
        GENOTYPHI_BWAMEM2.out.trace,
        SKA_SKETCH_TYPHI.out.trace,
        SKA_TYPE_WITH_PROFILE_TYPHI.out.trace,
        SKA_TYPE_NO_PROFILE_TYPHI.out.trace,
        BH_TYPHI.out.trace)
      .set { ch_trace }
  } else if (params.mtb_input && !params.typhi_input) {
    BH_MTB.out.trace
      .mix(
        SKA_SKETCH_MTB.out.trace,
        SKA_TYPE_NO_PROFILE_MTB.out.trace,
        TB_PROFILER.out.trace)
      .set { ch_trace }
  } else {
    exit 1, "Cannot create trace table without any output!"
  }

  ch_trace.collectFile() { sample_id, organism, coverage, proc_name, trace_file ->
      ['trace.txt', 
       """
       ${trace_file.text}
       sample_id=${sample_id}
       organism=${organism}
       coverage=${coverage}
       threads=1
       process_name=${proc_name}
       @@@
       """.stripIndent()]
    } \
    | TRACE_TABLE
}
