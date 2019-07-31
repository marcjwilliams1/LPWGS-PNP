rule fastQC:
    input:
        expand(config["fastqfiles"] + "{{file}}_{reads}_001.fastq.gz", reads = ["R1", "R2"])
    output:
        expand("fastQC/{{file}}_{reads}_001_fastqc.html", reads = ["R1", "R2"])
    threads: 1
    shell:
        """
        echo "Loading fastQC"
        module load fastqc
        fastqc {input} -o fastQC/
        """
