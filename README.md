# Benchmark biohansel, SKA, genotyphi and tb-profiler

- simulate reads at desired fold coverage with ART
- type *Salmonella* Typhi genomes with 
  - biohansel using S. Typhi scheme, 
  - genotyphi and 
  - SKA with adapted biohansel S. Typhi scheme
- type *Mycobacterium tuberculosis* (MTB) genomes with 
  - biohansel using MTB scheme, 
  - SKA with adapted biohansel MTB scheme and 
  - tb-profiler
- collect Nextflow trace information for performance comparison (time/CPU/memory usage)

See [environment.yml](environment.yml) for program versions installed from Bioconda.

## Usage

Basic local usage with `conda` profile for Nextflow Conda env creation with S. Typhi and MTB genome FASTA files specified (*NOTE: quotes needed to avoid shell expansion*)

```bash
$ nextflow run peterk87/nf-bh-typing-comparison \
    -profile conda \
    --typhi_input "/path/to/typhi/*.fasta" \
    --mtb_input "/path/to/mtb/*.fasta" \
    -resume
```

### Running with Slurm

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



## Output

- Typing output can be found in `results/mtb/{tool}/results` and `results/typhi/{tool}/results`
- CSV trace info table can be found in `results/trace/trace.csv`
- Nextflow generated pipeline execution info can be found in `results/pipeline_info`

### Example output directory tree

```
.
├── mtb
│   ├── biohansel
│   │   ├── results
│   │   │   ├── biohansel-detailed_report-DRR034342-50X.tsv
│   │   │   ├── biohansel-detailed_report-ERR1193763-50X.tsv
│   │   │   ├── biohansel-summary_report-DRR034342-50X.tsv
│   │   │   └── biohansel-summary_report-ERR1193763-50X.tsv
│   │   └── trace
│   │       ├── DRR034342-50X.trace
│   │       └── ERR1193763-50X.trace
│   ├── ska_sketch
│   │   ├── results
│   │   │   ├── DRR034342.skf
│   │   │   └── ERR1193763.skf
│   │   └── trace
│   │       ├── DRR034342-50X.trace
│   │       └── ERR1193763-50X.trace
│   ├── ska_type_no_profile
│   │   ├── results
│   │   │   ├── DRR034342-50X.tsv
│   │   │   └── ERR1193763-50X.tsv
│   │   └── trace
│   │       ├── DRR034342-50X.trace
│   │       └── ERR1193763-50X.trace
│   └── tb-profiler
│       ├── DRR034342
│       │   └── tb_profiler-DRR034342-50X
│       └── ERR1193763
│           └── tb_profiler-ERR1193763-50X
├── pipeline_info
│   ├── execution_dag.dot
│   ├── execution_report.html
│   ├── execution_timeline.html
│   └── execution_trace.txt
├── trace
│   └── trace.csv
└── typhi
    ├── biohansel
    │   ├── results
    │   │   ├── biohansel-detailed_report-ERR1017040-50X.tsv
    │   │   ├── biohansel-detailed_report-ERR343250-50X.tsv
    │   │   ├── biohansel-detailed_report-ERR360655-50X.tsv
    │   │   ├── biohansel-summary_report-ERR1017040-50X.tsv
    │   │   ├── biohansel-summary_report-ERR343250-50X.tsv
    │   │   └── biohansel-summary_report-ERR360655-50X.tsv
    │   └── trace
    │       ├── ERR1017040-50X.trace
    │       ├── ERR343250-50X.trace
    │       └── ERR360655-50X.trace
    ├── genotyphi
    │   ├── results
    │   │   ├── ERR1017040-50X-genotyphi.tsv
    │   │   ├── ERR343250-50X-genotyphi.tsv
    │   │   └── ERR360655-50X-genotyphi.tsv
    │   └── trace
    │       ├── ERR1017040-50X.trace
    │       ├── ERR343250-50X.trace
    │       └── ERR360655-50X.trace
    ├── ska_sketch
    │   ├── results
    │   │   ├── ERR1017040.skf
    │   │   ├── ERR343250.skf
    │   │   └── ERR360655.skf
    │   └── trace
    │       ├── ERR1017040-50X.trace
    │       ├── ERR343250-50X.trace
    │       └── ERR360655-50X.trace
    ├── ska_type_no_profile
    │   ├── results
    │   │   ├── ERR1017040-50X.tsv
    │   │   ├── ERR343250-50X.tsv
    │   │   └── ERR360655-50X.tsv
    │   └── trace
    │       ├── ERR1017040-50X.trace
    │       ├── ERR343250-50X.trace
    │       └── ERR360655-50X.trace
    └── ska_type_with_profile
        ├── results
        │   ├── ERR1017040-50X.tsv
        │   ├── ERR343250-50X.tsv
        │   └── ERR360655-50X.tsv
        └── trace
            ├── ERR1017040-50X.trace
            ├── ERR343250-50X.trace
            └── ERR360655-50X.trace
```

### Example trace.csv


Rendered table:

 | realtime | %cpu | rchar | wchar | syscr | syscw | read_bytes | write_bytes | %mem | vmem | rss | peak_vmem | peak_rss | vol_ctxt | inv_ctxt | sample_id | organism | coverage | threads | process_name
 | -------- | ---- | ----- | ----- | ----- | ----- | ---------- | ----------- | ---- | ---- | --- | --------- | -------- | -------- | -------- | --------- | -------- | -------- | ------- | ------------
0 | 16046 | 813 | 54291000 | 962 | 7019 | 14 | 0 | 4096 | 8 | 541064 | 534916 | 541064 | 534916 | 1 | 2424 | ERR1017040 | typhi | 50 | 1 | ska_type_no_profile
1 | 10374 | 967 | 491090840 | 13909 | 60232 | 15 | 0 | 20480 | 1 | 728816 | 65852 | 728816 | 65852 | 1 | 797 | ERR360655 | typhi | 50 | 1 | biohansel
2 | 242764 | 915 | 485007609 | 51706171 | 29873 | 6354 | 0 | 51707904 | 16 | 1059408 | 1053040 | 1059408 | 1053040 | 3 | 26386 | ERR343250 | typhi | 50 | 1 | ska_sketch
3 | 361786 | 3608 | 1626922293 | 963307303 | 192019 | 85629 | 0 | 155062272 | 9 | 1457752 | 625568 | 1460592 | 625804 | 101605 | 1301 | ERR360655 | typhi | 50 | 1 | genotyphi
4 | 15041 | 835 | 51773769 | 961 | 6712 | 14 | 0 | 4096 | 8 | 524408 | 518432 | 524408 | 518432 | 1 | 2132 | ERR360655 | typhi | 50 | 1 | ska_type_no_profile
5 | 236178 | 918 | 481707854 | 51336638 | 29671 | 6309 | 0 | 51339264 | 16 | 1054524 | 1048040 | 1054524 | 1048040 | 2 | 26532 | ERR360655 | typhi | 50 | 1 | ska_sketch
6 | 351626 | 1065 | 3196884422 | 1404139534 | 377270 | 206640 | 8192 | 858497024 | 7 | 4661136 | 552028 | 4726660 | 552028 | 42044 | 11216 | ERR1193763 | mtb | 50 | 1 | tb_profiler
7 | 11633 | 554 | 47248621 | 831 | 6134 | 14 | 0 | 4096 | 7 | 446064 | 439980 | 446064 | 439980 | 1 | 1303 | DRR034342 | mtb | 50 | 1 | ska_type_no_profile
8 | 14851 | 853 | 51785047 | 965 | 6715 | 14 | 0 | 4096 | 8 | 524408 | 518236 | 524408 | 518236 | 1 | 1324 | ERR360655 | typhi | 50 | 1 | ska_type_with_profile
9 | 8567 | 1016 | 448954212 | 11014 | 55087 | 15 | 0 | 16384 | 1 | 728816 | 65648 | 728816 | 65648 | 2 | 1849 | DRR034342 | mtb | 50 | 1 | biohansel
10 | 308049 | 1070 | 3198497602 | 1405389862 | 377272 | 206831 | 16384 | 859598848 | 7 | 4661140 | 552256 | 4661792 | 552256 | 45350 | 8340 | DRR034342 | mtb | 50 | 1 | tb_profiler
11 | 261713 | 893 | 505087904 | 53853874 | 31099 | 6616 | 0 | 53854208 | 17 | 1099404 | 1092772 | 1099404 | 1092772 | 2 | 43575 | ERR1017040 | typhi | 50 | 1 | ska_sketch
12 | 11152 | 944 | 514470889 | 14143 | 63086 | 15 | 0 | 20480 | 1 | 728816 | 65884 | 728816 | 65884 | 1 | 823 | ERR1017040 | typhi | 50 | 1 | biohansel
13 | 15604 | 863 | 54302279 | 967 | 7022 | 14 | 0 | 4096 | 8 | 541064 | 535024 | 541064 | 535024 | 1 | 2792 | ERR1017040 | typhi | 50 | 1 | ska_type_with_profile
14 | 9942 | 944 | 494390592 | 13910 | 60636 | 15 | 0 | 20480 | 1 | 728816 | 65904 | 728816 | 65904 | 2 | 1150 | ERR343250 | typhi | 50 | 1 | biohansel
15 | 202469 | 928 | 439576618 | 46812769 | 27101 | 5757 | 0 | 46813184 | 15 | 968460 | 962076 | 968460 | 962076 | 1 | 29363 | DRR034342 | mtb | 50 | 1 | ska_sketch
16 | 201362 | 926 | 438493653 | 46733840 | 27035 | 5747 | 0 | 46735360 | 15 | 967272 | 960824 | 967272 | 960824 | 1 | 31019 | ERR1193763 | mtb | 50 | 1 | ska_sketch
17 | 8100 | 1094 | 447871248 | 11207 | 54955 | 15 | 0 | 16384 | 1 | 728816 | 65592 | 728816 | 65592 | 2 | 1058 | ERR1193763 | mtb | 50 | 1 | biohansel
18 | 10651 | 628 | 47169687 | 832 | 6124 | 14 | 0 | 4096 | 7 | 445404 | 439456 | 445404 | 439456 | 1 | 1358 | ERR1193763 | mtb | 50 | 1 | ska_type_no_profile
19 | 14698 | 851 | 52143302 | 961 | 6757 | 14 | 0 | 4096 | 8 | 524408 | 518472 | 524408 | 518472 | 1 | 850 | ERR343250 | typhi | 50 | 1 | ska_type_no_profile
20 | 16306 | 769 | 52154582 | 966 | 6760 | 14 | 0 | 4096 | 8 | 524408 | 518376 | 524408 | 518376 | 1 | 3291 | ERR343250 | typhi | 50 | 1 | ska_type_with_profile
21 | 358875 | 3641 | 1631796863 | 965173578 | 192844 | 86112 | 0 | 154771456 | 9 | 1457240 | 624024 | 1457500 | 624184 | 101105 | 1184 | ERR343250 | typhi | 50 | 1 | genotyphi
22 | 208627 | 3756 | 1674231279 | 987134601 | 198544 | 88741 | 0 | 155168768 | 10 | 1457496 | 626896 | 1457756 | 627124 | 63579 | 663 | ERR1017040 | typhi | 50 | 1 | genotyphi

Raw CSV:


```
,realtime,%cpu,rchar,wchar,syscr,syscw,read_bytes,write_bytes,%mem,vmem,rss,peak_vmem,peak_rss,vol_ctxt,inv_ctxt,sample_id,organism,coverage,threads,process_name
0,16046,813,54291000,962,7019,14,0,4096,8,541064,534916,541064,534916,1,2424,ERR1017040,typhi,50,1,ska_type_no_profile
1,10374,967,491090840,13909,60232,15,0,20480,1,728816,65852,728816,65852,1,797,ERR360655,typhi,50,1,biohansel
2,242764,915,485007609,51706171,29873,6354,0,51707904,16,1059408,1053040,1059408,1053040,3,26386,ERR343250,typhi,50,1,ska_sketch
3,361786,3608,1626922293,963307303,192019,85629,0,155062272,9,1457752,625568,1460592,625804,101605,1301,ERR360655,typhi,50,1,genotyphi
4,15041,835,51773769,961,6712,14,0,4096,8,524408,518432,524408,518432,1,2132,ERR360655,typhi,50,1,ska_type_no_profile
5,236178,918,481707854,51336638,29671,6309,0,51339264,16,1054524,1048040,1054524,1048040,2,26532,ERR360655,typhi,50,1,ska_sketch
6,351626,1065,3196884422,1404139534,377270,206640,8192,858497024,7,4661136,552028,4726660,552028,42044,11216,ERR1193763,mtb,50,1,tb_profiler
7,11633,554,47248621,831,6134,14,0,4096,7,446064,439980,446064,439980,1,1303,DRR034342,mtb,50,1,ska_type_no_profile
8,14851,853,51785047,965,6715,14,0,4096,8,524408,518236,524408,518236,1,1324,ERR360655,typhi,50,1,ska_type_with_profile
9,8567,1016,448954212,11014,55087,15,0,16384,1,728816,65648,728816,65648,2,1849,DRR034342,mtb,50,1,biohansel
10,308049,1070,3198497602,1405389862,377272,206831,16384,859598848,7,4661140,552256,4661792,552256,45350,8340,DRR034342,mtb,50,1,tb_profiler
11,261713,893,505087904,53853874,31099,6616,0,53854208,17,1099404,1092772,1099404,1092772,2,43575,ERR1017040,typhi,50,1,ska_sketch
12,11152,944,514470889,14143,63086,15,0,20480,1,728816,65884,728816,65884,1,823,ERR1017040,typhi,50,1,biohansel
13,15604,863,54302279,967,7022,14,0,4096,8,541064,535024,541064,535024,1,2792,ERR1017040,typhi,50,1,ska_type_with_profile
14,9942,944,494390592,13910,60636,15,0,20480,1,728816,65904,728816,65904,2,1150,ERR343250,typhi,50,1,biohansel
15,202469,928,439576618,46812769,27101,5757,0,46813184,15,968460,962076,968460,962076,1,29363,DRR034342,mtb,50,1,ska_sketch
16,201362,926,438493653,46733840,27035,5747,0,46735360,15,967272,960824,967272,960824,1,31019,ERR1193763,mtb,50,1,ska_sketch
17,8100,1094,447871248,11207,54955,15,0,16384,1,728816,65592,728816,65592,2,1058,ERR1193763,mtb,50,1,biohansel
18,10651,628,47169687,832,6124,14,0,4096,7,445404,439456,445404,439456,1,1358,ERR1193763,mtb,50,1,ska_type_no_profile
19,14698,851,52143302,961,6757,14,0,4096,8,524408,518472,524408,518472,1,850,ERR343250,typhi,50,1,ska_type_no_profile
20,16306,769,52154582,966,6760,14,0,4096,8,524408,518376,524408,518376,1,3291,ERR343250,typhi,50,1,ska_type_with_profile
21,358875,3641,1631796863,965173578,192844,86112,0,154771456,9,1457240,624024,1457500,624184,101105,1184,ERR343250,typhi,50,1,genotyphi
22,208627,3756,1674231279,987134601,198544,88741,0,155168768,10,1457496,626896,1457756,627124,63579,663,ERR1017040,typhi,50,1,genotyphi
```

