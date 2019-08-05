def _get_matchesR1(wildcards):
    return sorted(glob.glob(config["fastqfiles"] + wildcards.sample + "*R1*.fastq.gz"))
def _get_matchesR2(wildcards):
    return sorted(glob.glob(config["fastqfiles"] + wildcards.sample + "*R1*.fastq.gz"))

rule mergefastq:
    input:
        R1=_get_matchesR1,
        R2=_get_matchesR2,
    output:
        tempfastqR1="tempfastq/{sample}.R1.fastq.gz",
        tempfastqR2="tempfastq/{sample}.R2.fastq.gz"
    shell:
        """
        cat {input.R1} > {output.tempfastqR1}
        cat {input.R2} > {output.tempfastqR2}
        """

rule align:
    input:
        tempfastqR1="tempfastq/{sample}.R1.fastq.gz",
        tempfastqR2="tempfastq/{sample}.R2.fastq.gz"
    output:
        "tempbams/{sample}.bam"
    threads: 1
    params:
        genome=config["genome"]
    shell:
        """
        module load bwa/0.7.15
        module load samtools/1.8

        bwa mem -M -t {threads} \
        {params.genome} \
        {input.tempfastqR1} {input.tempfastqR2} | \
        samtools view -S -b - > {output}.temp.bam

        module load java
        java -jar -Xmx4G $PICARD AddOrReplaceReadGroups \
           I={output}.temp.bam \
           O={output} \
           RGID=${{sample}} \
           RGLB=${{sample}} \
           RGPL=ILLUMINA \
           RGSM=${{sample]}} \
           RGPU=${{sample}}

        rm {input.tempfastqR1}
        rm {input.tempfastqR2}
        rm {output}.temp.bam
        """

rule indexdedupbam:
    input:
        bam="tempbams/{sample}.bam",
    output:
        bam="bams/{sample}.bam",
        metrics="QC/dedupmetrics/{sample}.dedup.txt"
    threads: 1
    shell:
        """
        module load java
        java -jar -Xmx4G $PICARD MarkDuplicates \
        INPUT={input.bam} \
        OUTPUT={output.bam} \
        METRICS_FILE={output.metrics}.temp \
        CREATE_INDEX=true \
        REMOVE_DUPLICATES=true

	    grep -A2  "## METRICS" {output.metrics}.temp | tail -n +1 > {output.metrics}
        rm {output.metrics}.temp
        """
