process ART {
  tag "$fasta_id - ${coverage}X"
  input:
  tuple path(fasta),
        val(organism),
        val(coverage)

  output:
  tuple path(fasta),
        val(organism),
        val(coverage),
        path("${out_prefix}{1,2}.fq")

  script:
  fasta_id = file(fasta).getBaseName()
  out_prefix = "${fasta_id}-${organism}-${coverage}X_"
  """
  art_illumina \\
    --seqSys ${params.art_seq_sys} \\
    -i $fasta \\
    -o $out_prefix \\
    --paired \\
    --fcov $coverage \\
    --len ${params.art_read_length} \\
    --mflen ${params.art_mean_fragment_length} \\
    --sdev ${params.art_fragment_length_sdev} \\
    --rndSeed ${params.art_random_seed}
  """
}