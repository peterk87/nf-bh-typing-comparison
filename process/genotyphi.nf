process BOWTIE2_INDEX {
  input:
  path(fasta)
  output:
  tuple path(fasta), path('bt2-index/'), val(index_prefix)

  script:
  index_prefix = file(fasta).getSimpleName()
  """
  bowtie2-build -f $fasta $index_prefix
  mkdir -p bt2-index
  mv *.bt2 bt2-index/
  """
}

process GENOTYPHI {
  publishDir "${params.outdir}/typhi/genotyphi/results", 
             pattern: "*.tsv", 
             mode: 'copy'
  publishDir "${params.outdir}/typhi/genotyphi/trace", 
             pattern: ".command.trace",
             saveAs: {"${sample_id}-${mincov}X.trace"},
             mode: 'copy'
  input:
  tuple path(input_fasta), 
        val(organism), 
        val(mincov),
        path(reads),
        path(ref_fasta),
        path(ref_index),
        val(index_prefix)
  output:
  tuple val(sample_id),
        path(genotyphi_out), emit: 'results'
  tuple val(sample_id),
        val(organism),
        val(mincov),
        val('genotyphi'),
        path('.command.trace'), emit: 'trace'

  script:
  sample_id = file(input_fasta).getBaseName()
  ref_id = file(ref_fasta).getBaseName()
  genotyphi_out = "${sample_id}-${mincov}X-genotyphi.tsv"
  bt2_index = "${file(ref_index).getBaseName()}/${index_prefix}"
  bam = "${sample_id}.bam"
  """
  echo "bowtie2 mapping reads $reads to index at $bt2_index"
  bowtie2 \\
      -p ${task.cpus} \\
      -x $bt2_index \\
      --local \\
      -1 ${reads[0]} \\
      -2 ${reads[1]} \\
    | samtools view -b -h -O BAM -F4 \\
    | samtools sort -o $bam
  samtools index $bam
  genotyphi.py --mode bam \\
    --bam $bam \\
    --ref $ref_fasta \\
    --ref_id $ref_id \\
    --output $genotyphi_out
  """
}

process GENOTYPHI_BWAMEM2 {
  publishDir "${params.outdir}/typhi/genotyphi_bwamem2/results", 
             pattern: "*.tsv", 
             mode: 'copy'
  publishDir "${params.outdir}/typhi/genotyphi_bwamem2/trace", 
             pattern: ".command.trace",
             saveAs: {"${sample_id}-${mincov}X.trace"},
             mode: 'copy'
  input:
  tuple path(input_fasta), 
        val(organism), 
        val(mincov),
        path(reads),
        path(ref_fasta)
  output:
  tuple val(sample_id),
        path(genotyphi_out), emit: 'results'
  tuple val(sample_id),
        val(organism),
        val(mincov),
        val('genotyphi_bwamem2'),
        path('.command.trace'), emit: 'trace'

  script:
  sample_id = file(input_fasta).getBaseName()
  ref_id = file(ref_fasta).getBaseName()
  genotyphi_out = "${sample_id}-${mincov}X-genotyphi.tsv"
  bam = "${sample_id}.bam"
  """
  echo "BWA MEM 2 mapping reads $reads"
  bwa-mem2 index -p bm2-idx $ref_fasta
  bwa-mem2 mem \\
      -t ${task.cpus} \\
      bm2-idx \\
      ${reads} \\
    | samtools view -b -h -O BAM -F4 \\
    | samtools sort -o $bam
  samtools index $bam
  genotyphi.py --mode bam \\
    --bam $bam \\
    --ref $ref_fasta \\
    --ref_id $ref_id \\
    --output $genotyphi_out
  """
}