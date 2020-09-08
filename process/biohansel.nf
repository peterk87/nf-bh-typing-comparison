process BIOHANSEL {
  tag "$organism|$sample_id"
  publishDir "$params.outdir/$organism/biohansel/results",
             mode: 'copy',
             pattern: "*.tsv"
  publishDir "${params.outdir}/$organism/biohansel/trace",
             pattern: ".command.trace",
             saveAs: { "${sample_id}-${coverage}X.trace" },
             mode: 'copy'

  input:
  tuple path(sample_fasta),
        val(organism),
        val(coverage),
        path(reads),
        path(scheme_fasta),
        path(metadata_tsv)
  output:
  tuple val(sample_id),
        val(organism),
        val(coverage),
        path(detailed_report),
        path(summary_report), emit: 'results'
  tuple val(sample_id),
        val(organism),
        val(coverage),
        val('biohansel'),
        path('.command.trace'), emit: 'trace'
  script:
  sample_id = file(sample_fasta).getBaseName()
  detailed_report = "biohansel-detailed_report-${sample_id}-${coverage}X.tsv"
  summary_report = "biohansel-summary_report-${sample_id}-${coverage}X.tsv"
  """
  hansel \\
    -v \\
    -t 1 \\
    --min-kmer-freq ${params.typhi_biohansel_mincov} \\
    -s $scheme_fasta \\
    --scheme-name $organism \\
    -M $metadata_tsv \\
    -p $reads \\
    -o $summary_report \\
    -O $detailed_report
  """
}