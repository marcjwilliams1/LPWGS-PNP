# The main entry point of your workflow.
# After configuring, running snakemake -n in a clone of this repository should successfully execute a dry-run of the workflow.
import os
import glob

configfile: "config.yaml"
report: "report/workflow.rst"
workdir: config["workdirectory"]

# Allow users to fix the underlying OS via singularity.
#singularity: "docker://continuumio/miniconda3"

fastqfiles = [f for f in glob.glob(config["fastqfiles"] + "/*.gz", recursive=True)]
(FILES,)=glob_wildcards(config["fastqfiles"] + "{FILES}_R1_001.fastq.gz")
(RUNID,SAMPLES,S,LANES)=glob_wildcards(config["fastqfiles"] + "GC-{RUNID}-{SAMPLES}_{S}_{LANES}_R1_001.fastq.gz")

runid=["_{}_{}".format(a_, b_) for a_, b_ in zip(S, LANES)]

SAMPLES=list(set(SAMPLES))
#LANES=list(set(LANES))

def _get_matches(wildcards):
    return glob.glob(config["fastqfiles"] + "*" + wildcards.sample + "*.bam")

# def _get_matches(x):
#     return glob.glob(config["fastqfiles"] + "*" + x + "_*R1*.fastq.gz")


rule all:
    input:
        expand("fastQC/{sample}/", sample = SAMPLES),
        expand("bams/3.final/{sample}.bam", sample = SAMPLES),
        Rdata="CNcalling/finalresults." + config["binsize"] + ".Rdata",
        report="reports/results.html"


include: "rules/fastQC.smk"
include: "rules/align.smk"
include: "rules/QCmetrics.smk"
include: "rules/CNcalling.smk"
include: "rules/report.smk"
