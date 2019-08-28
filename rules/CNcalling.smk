rule CNcalling:
    input:
        bams=expand("bams/3.final/{sample}.bam", sample = SAMPLES)
    output:
        Rdata="CNcalling/finalresults." + config["binsize"] + ".Rdata",
        segmentfile="CNcalling/finalresults." + config["binsize"] + ".segments.txt",
        plotdir=directory("CNcalling/plots/binsize" + config["binsize"]),
        plotdirP=directory("CNcalling/plotsP/binsize" + config["binsize"]),
        plotdirNP=directory("CNcalling/plotsNP/binsize" + config["binsize"])
    threads: 1
    params:
        binsize=config["binsize"],
        filterP=config["progressors"],
        filterNP=config["nonprogressors"],
        singularityimage=config["singularityR"],
        pipelinedirectory=config["pipelinedirectory"]
    shell:
        """
        module load R
        module load singularity
        echo {params.filterP}
        echo {params.filterNP}

        singularity exec {params.singularityimage} \
        Rscript {params.pipelinedirectory}/scripts/QDNAseq.R \
            --bamfiles {input.bams} \
            --binsize {params.binsize} \
            --plotdir {output.plotdirP} \
            --Rdata {output.Rdata}.P.Rdata \
            --segmentfile {output.segmentfile}.NP.txt \
            --pipelinedirectory {params.pipelinedirectory} \
            --filter {params.filterP}

        singularity exec {params.singularityimage} \
        Rscript {params.pipelinedirectory}/scripts/QDNAseq.R \
            --bamfiles {input.bams} \
            --binsize {params.binsize} \
            --plotdir {output.plotdirNP} \
            --Rdata {output.Rdata}.NP.Rdata \
            --segmentfile {output.segmentfile}.NP.txt \
            --pipelinedirectory {params.pipelinedirectory} \
            --filter {params.filterNP}

        singularity exec {params.singularityimage} \
        Rscript {params.pipelinedirectory}/scripts/QDNAseq.R \
            --bamfiles {input.bams} \
            --binsize {params.binsize} \
            --plotdir {output.plotdir} \
            --Rdata {output.Rdata} \
            --segmentfile {output.segmentfile} \
            --pipelinedirectory {params.pipelinedirectory} \
            --filter ""
        """
