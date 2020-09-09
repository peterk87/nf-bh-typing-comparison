process SKA_SKETCH {
  tag "$organism|$sample_id"
  publishDir "${params.outdir}/$organism/ska_sketch/results",
             pattern: "*.skf"
  publishDir "${params.outdir}/$organism/ska_sketch/trace",
             pattern: ".command.trace",
             saveAs: { "${sample_id}-${coverage}X.trace" },
             mode: 'copy'
  input:
  tuple path(sample_fasta),
        val(organism),
        val(coverage),
        path(reads)

  output:
  tuple val(sample_id),
        val(organism),
        val(coverage),
        path("${sample_id}.skf"), emit: 'results'
  tuple val(sample_id),
        val(organism),
        val(coverage),
        val('ska_sketch'),
        path('.command.trace'), emit: 'trace'

  script:
  sample_id = file(sample_fasta).getBaseName()
  """
  ska fastq -o $sample_id $reads
  """
}

process SKA_TYPE_NO_PROFILE {
  tag "$organism|$sample_id"
  publishDir "${params.outdir}/$organism/ska_type_no_profile/results",
             pattern: "*.tsv",
             mode: 'copy'
  publishDir "${params.outdir}/$organism/ska_type_no_profile/trace",
             pattern: ".command.trace",
             saveAs: { "${sample_id}-${coverage}X.trace" },
             mode: 'copy'
  input:
  tuple val(sample_id),
        val(organism),
        val(coverage),
        path(sketch)
  path(marker_fastas)
  output:
  tuple val(sample_id),
        val(organism),
        val(coverage),
        path(output), emit: 'results'
  tuple val(sample_id),
        val(organism),
        val(coverage),
        val('ska_type_no_profile'),
        path('.command.trace'), emit: 'trace'

  script:
  output = "${sample_id}-${coverage}X.tsv"
  """
  ska type -q $sketch $marker_fastas > $output
  """
}

process SKA_TYPE_WITH_PROFILE {
  tag "$organism|$sample_id"
  publishDir "${params.outdir}/$organism/ska_type_with_profile/results",
             pattern: "*.tsv",
             mode: 'copy'
  publishDir "${params.outdir}/$organism/ska_type_with_profile/trace",
             pattern: ".command.trace",
             saveAs: { "${sample_id}-${coverage}X.trace" },
             mode: 'copy'
  errorStrategy 'ignore'
  input:
  tuple val(sample_id),
        val(organism),
        val(coverage),
        path(sketch)
  path(marker_fastas)
  path(profile)
  output:
  tuple val(sample_id),
        val(organism),
        val(coverage),
        path(output), emit: 'results'
  tuple val(sample_id),
        val(organism),
        val(coverage),
        val('ska_type_with_profile'),
        path('.command.trace'), emit: 'trace'

  script:
  output = "${sample_id}-${coverage}X.tsv"
  """
  ska type -q $sketch -p $profile $marker_fastas > $output
  """
}