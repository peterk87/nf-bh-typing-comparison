process TRACE_TABLE {
  publishDir "${params.outdir}/trace", mode: 'copy'
  input:
  file trace
  output:
  file trace_table_csv

  script:
  trace_table_csv = "trace.csv"
  """
  make_trace_table.py -t $trace -o $trace_table_csv 
  """
}