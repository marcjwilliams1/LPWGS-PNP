# The main entry point of your workflow.
# After configuring, running snakemake -n in a clone of this repository should successfully execute a dry-run of the workflow.
import os
import glob

configfile: "config.yaml"
report: "report/workflow.rst"
workdir: "/data/BCI-EvoCa2/marc/anisha/resultsnew/"

# Allow users to fix the underlying OS via singularity.
#singularity: "docker://continuumio/miniconda3"

fastqfiles = [f for f in glob.glob(config["fastqfiles"] + "/*.gz", recursive=True)]
(FILES,)=glob_wildcards(config["fastqfiles"] + "{FILES}_R1_001.fastq.gz")
(SAMPLES,S,LANES)=glob_wildcards(config["fastqfiles"] + "{SAMPLES}_{S}_{LANES}_R1_001.fastq.gz")

SAMPLES=list(set(SAMPLES))
#LANES=list(set(LANES))

rule all:
    input:
        expand("fastQC/{file}_R1_001_fastqc.html", file = FILES),
        expand("tempbams/{file}.bam", file = FILES),
        expand("bams/{sample}.bam", sample = SAMPLES),
        expand("QC/WGSmetrics/{sample}.txt", sample = SAMPLES),
        Rdata="CNcalling/finalresults." + config["binsize"] + ".Rdata",
        QC="QC/QCresults.csv",
        report="results/reports/QC.html"
        #expand("bams/{sample}.dedup.bam", sample = SAMPLES)
        # The first rule should define the default target files
        # Subsequent target rules can be specified below. They should start with all_*.

include: "rules/fastQC.smk"
include: "rules/align.smk"
include: "rules/mergebams.smk"
include: "rules/QCmetrics.smk"
include: "rules/CNcalling.smk"
include: "rules/report.smk"
