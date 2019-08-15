def _get_matchesR1(wildcards):
    return sorted(glob.glob(config["fastqfiles"] + "*" + wildcards.sample + "_*R1*.fastq.gz"))
def _get_matchesR2(wildcards):
    return sorted(glob.glob(config["fastqfiles"] + "*" + wildcards.sample + "_*R2*.fastq.gz"))

rule mergefastq:
    input:
        R1=_get_matchesR1,
        R2=_get_matchesR2,
    output:
        tempfastqR1="tempfastq/{sample}.R1.fastq.gz",
        tempfastqR2="tempfastq/{sample}.R2.fastq.gz"
    shell:
        """
        echo "Merging fastq files R1"
        echo "fastq files: "
        echo {input.R1}
        cat {input.R1} > {output.tempfastqR1}
        echo "Merging fastq files R2"
        echo "fastq files: "
        echo {input.R2}
        cat {input.R2} > {output.tempfastqR2}
        echo "Finished merging fastqfiles"
        """

rule align:
    input:
        tempfastqR1="tempfastq/{sample}.R1.fastq.gz",
        tempfastqR2="tempfastq/{sample}.R2.fastq.gz"
    output:
        "bams/1.align/{sample}.bam"
    threads: 4
    params:
        genome=config["genome"],
        picard=config["picard"]
    shell:
        """
        module load bwa/0.7.15
        module load samtools/1.8

        bwa mem -M -t {threads} \
        {params.genome} \
        {input.tempfastqR1} {input.tempfastqR2} | \
        samtools view -S -b - > {output}.temp.bam

        module load java
        java -jar -Xmx2G {params.picard} AddOrReplaceReadGroups \
           I={output}.temp.bam \
           O={output} \
           RGID={wildcards.sample} \
           RGLB={wildcards.sample} \
           RGPL=ILLUMINA \
           RGSM={wildcards.sample} \
           RGPU={wildcards.sample}

        rm {input.tempfastqR1}
        rm {input.tempfastqR2}
        rm {output}.temp.bam
        """

rule sortbam:
    input:
        bam="bams/1.align/{sample}.bam",
    output:
        bam="bams/2.sorted/{sample}.bam"
    params:
        picard=config["picard"]
    shell:
        """
        module load java
        java -jar -Xmx4G {params.picard} SortSam \
            INPUT={input.bam} \
            OUTPUT={output.bam} \
            SORT_ORDER=coordinate
        """

rule indexdedupbam:
    input:
        bam="bams/2.sorted/{sample}.bam",
    output:
        bam="bams/3.final/{sample}.bam",
        metrics="QC/dedupmetrics/{sample}.txt"
    params:
        picard=config["picard"]
    threads: 1
    shell:
        """
        module load java
        java -jar -Xmx4G {params.picard} MarkDuplicates \
            INPUT={input.bam} \
            OUTPUT={output.bam} \
            METRICS_FILE={output.metrics}.temp \
            CREATE_INDEX=true \
            REMOVE_DUPLICATES=true

	    grep -A2  "## METRICS" {output.metrics}.temp | tail -n +1 > {output.metrics}
        rm {output.metrics}.temp
        """
