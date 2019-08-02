rule align:
    input:
        R1=config["fastqfiles"] + "{file}_R1_001.fastq.gz",
        R2=config["fastqfiles"] + "{file}_R2_001.fastq.gz",
    output:
        "tempbams/{file}.merge.bam"
    threads: 1
    params:
        genome=config["genome"]
    shell:
        """
        module load bwa/0.7.15
        module load samtools/1.8

        IFS='_' read -r -a array <<< {wildcards.file}
        echo ${{array}}

        readgroup='@RG\\tID:${{array[0]}}\\tLB:${{array[0]}}\\tSM:${{array[0]}}\\tPL:ILLUMINA'
        echo $readgroup

        bwa mem -M -t {threads} \
        {params.genome} \
        {input.R1} {input.R2} | \
        samtools view -S -b -q 37 - > {output}.temp.bam

        module load java
        java -jar -Xmx4G $PICARD AddOrReplaceReadGroups \
           I={output}.temp.bam \
           O={output} \
           RGID=${{array[0]}} \
           RGLB=${{array[0]}} \
           RGPL=ILLUMINA \
           RGSM=${{array[0]}} \
           RGPU=${{array[0]}}

        rm {output}.temp.bam
        """
