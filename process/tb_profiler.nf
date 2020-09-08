process TB_PROFILER {
  publishDir "${params.outdir}/${organism}/tb-profiler/$sample_id"
  input:
  tuple path(sample_fasta),
        val(organism),
        val(coverage),
        path(reads)

  output:
  tuple val(sample_id),
        path("${tb_profiler_outdir}/"), emit: 'results'
  tuple val(sample_id),
        val(organism),
        val(coverage),
        val('tb_profiler'),
        path('.command.trace'), emit: 'trace'

  script:
  sample_id = file(sample_fasta).getBaseName()
  tb_profiler_outdir = "tb_profiler-${sample_id}-${coverage}X"
  """
  tb-profiler profile \\
    --threads ${task.cpus} \\
    --read1 ${reads[0]} \\
    --read2 ${reads[1]} \\
    --txt \\
    --csv \\
    --prefix ${sample_id}-${coverage}X \\
    --dir $tb_profiler_outdir
  """
}