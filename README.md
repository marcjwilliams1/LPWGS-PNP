# Snakemake workflow: LPWGS

This is a snakemake workflow to get copy number calls from low-pass whole genome sequencing. It aligns fastq files, performs some QC and then runs QDNAseq.

## Authors

* Marc Williams (@marcjwilliams1)

## Usage

### Simple

#### Step 1: Install workflow

If you simply want to use this workflow, download and extract the [latest release](https://github.com/snakemake-workflows/LPWGS-PNP/releases).
If you intend to modify and further extend this workflow or want to work under version control, fork this repository as outlined in [Advanced](#advanced). The latter way is recommended.


#### Step 2: Configure workflow

Configure the workflow according to your needs via editing the file `config.yaml`.

#### Step 3: Execute workflow

Make sure you have snakemake installed on your hpc. If running on apocrita (QMUL hpc) you may need to install it in an environment. eg I run the following to activate an environment with snakemake installed.
```
source /data/home/hfx042/bin/snakemake/bin/activate
```

You can then run a dry-run to check all rules have correct dependencies:
```
snakemake -n
```

Finally to run the workflow using the job scheduling on apocrita you can use the following:

```
snakemake --jobs 75 \
  --cluster-config cluster.yaml \
  --cluster "qsub -cwd -l h_rt={cluster.time} -l h_vmem={cluster.mem} -pe smp {threads} -o {cluster.output} -j y -N {cluster.name}"
```

If you're using a different HPC you may need to change this command and the cluster configuration file ```cluster.yaml```.
