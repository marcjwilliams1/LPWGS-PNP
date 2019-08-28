def _get_matchesR1(wildcards):
    return sorted(glob.glob(config["fastqfiles"] + "*" + wildcards.sample + "_*R1*.fastq.gz"))
def _get_matchesR2(wildcards):
    return sorted(glob.glob(config["fastqfiles"] + "*" + wildcards.sample + "_*R2*.fastq.gz"))

rule fastQC:
    input:
        R1=_get_matchesR1,
        R2=_get_matchesR2,
    output:
        directory("fastQC/{sample}/")
    threads: 1
    shell:
        """
        echo "Loading fastQC"
        module load fastqc
        fastqc {input.R1} -o {output}
        fastqc {input.R2} -o {output}
        """
