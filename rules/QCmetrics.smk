rule QCmetrics:
    input:
        bam="bams/3.final/{sample}.bam",
    output:
        metricsWGS="QC/WGSmetrics/{sample}.txt",
        metricsInsert="QC/Insertmetrics/{sample}.txt",
        metricsAlign="QC/alignmentmetrics/{sample}.txt",
        metricsQS="QC/qualityscoremetrics/{sample}.txt",
    threads: 1
    params:
        genome=config["genome"],
        picard=config["picard"]
    shell:
        """
        longLine="--------------------"
        module load java
        module load R

        msg="Run picard CollectWGSMetrics"; echo "-- $msg $longLine"; >&2 echo "-- $msg $longLine"

        java -jar -Xmx4G {params.picard} CollectWgsMetrics \
            INPUT={input.bam} \
            OUTPUT={output.metricsWGS}.temp \
            R={params.genome}
        grep -A2  "## METRICS" {output.metricsWGS}.temp | tail -n +1 > {output.metricsWGS}
        rm {output.metricsWGS}.temp


        msg="Run picard insertsize metrics"; echo "-- $msg $longLine"; >&2 echo "-- $msg $longLine"
        java -jar -Xmx4G {params.picard} CollectInsertSizeMetrics \
            INPUT={input.bam} \
            OUTPUT={output.metricsInsert}.temp \
            H={output.metricsInsert}.pdf
        grep -A2  "## METRICS" {output.metricsInsert}.temp | tail -n +1 > {output.metricsInsert}
        rm {output.metricsInsert}.temp

        msg="Run picard CollectAlignmentSummaryMetrics"; echo "-- $msg $longLine"; >&2 echo "-- $msg $longLine"
        java -jar -Xmx4G {params.picard} CollectAlignmentSummaryMetrics \
            INPUT={input.bam} \
            OUTPUT={output.metricsAlign}.temp \
            ADAPTER_SEQUENCE=[CTGTCTCTTATA,TCGTCGGCAGCGTCAGATGTGTATAAGAGACAG,GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAG,AGATCGGAAGAGC,ACGCTCTTCCGATCT] \
            R={params.genome}
        grep -A2  "## METRICS" {output.metricsAlign}.temp | tail -n +1 > {output.metricsAlign}
        rm {output.metricsAlign}.temp

        msg="Run picard QualityScoreDistribution"; echo "-- $msg $longLine"; >&2 echo "-- $msg $longLine"
        java -jar -Xmx4G {params.picard} QualityScoreDistribution \
            INPUT={input.bam} \
            OUTPUT={output.metricsQS} \
            CHART={output.metricsQS}.pdf

        """

rule combineQCmetrics:
        input:
            metricsWGS=expand("QC/WGSmetrics/{sample}.txt", sample = SAMPLES),
            metricsInsert=expand("QC/Insertmetrics/{sample}.txt", sample = SAMPLES),
            metricsAlign=expand("QC/alignmentmetrics/{sample}.txt", sample = SAMPLES),
            metricsDedup=expand("QC/dedupmetrics/{sample}.txt", sample = SAMPLES),
        output:
            "QC/QCresults.csv"
        params:
            singularityimage=config["singularityR"],
            pipelinedirectory=config["pipelinedirectory"]
        threads: 1
        shell:
            """
            module load singularity
            singularity exec {params.singularityimage} \
            Rscript {params.pipelinedirectory}/scripts/combineQC.R \
                --WGS {input.metricsWGS} \
                --insertsize {input.metricsInsert} \
                --align {input.metricsAlign} \
                --dedup {input.metricsDedup} \
                --output {output}
            """
