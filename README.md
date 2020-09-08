# Benchmark biohansel, SKA, genotyphi and tb-profiler

- simulate reads at desired fold coverage with ART
- type *Salmonella* Typhi genomes with biohansel using S. Typhi scheme, genotyphi and SKA with adapted biohansel S. Typhi scheme
- type *Mycobacterium tuberculosis* (MTB) genomes with biohansel using MTB scheme, SKA with adapted biohansel MTB scheme and tb-profiler
- collect Nextflow trace information for performance comparison (time/CPU/memory usage)

## Usage

Basic local usage with `conda` profile for Nextflow Conda env creation with S. Typhi and MTB genome FASTA files specified (*NOTE: quotes needed to avoid shell expansion*)

```bash
$ nextflow run peterk87/nf-bh-typing-comparison \
    -profile conda \
    --typhi_input "/path/to/typhi/*.fasta" \
    --mtb_input "/path/to/mtb/*.fasta" \
    -resume
```

## Running with Slurm

Run using Slurm scheduler:

```bash
$ nextflow run peterk87/nf-bh-typing-comparison \
    -profile conda,slurm \
    --slurm_queue InsertSlurmQueueName \
    --slurm_queue_size 50 \
    --typhi_input "/path/to/typhi/*.fasta" \
    --mtb_input "/path/to/mtb/*.fasta" \
    -resume
```

- set `slurm_queue` to the name of Slurm queue or partition you wish to run the workflow on
- set `slurm_queue_size` to a reasonable size so you don't get in trouble with your cluster admins
