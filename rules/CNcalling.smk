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
        filterNP=config["nonprogressors"]
    shell:
        """
        module load R
        echo {params.filterP}
        echo {params.filterNP}

        Rscript /data/BCI-EvoCa2/marc/anisha/LPWGS-PNP/scripts/QDNAseq.R \
            --bamfiles {input.bams} \
            --binsize {params.binsize} \
            --plotdir {output.plotdirNP} \
            --Rdata {output.Rdata}.NP.Rdata \
            --segmentfile {output.segmentfile}.NP.txt \
            --filter {params.filterNP}

        Rscript /data/BCI-EvoCa2/marc/anisha/LPWGS-PNP/scripts/QDNAseq.R \
            --bamfiles {input.bams} \
            --binsize {params.binsize} \
            --plotdir {output.plotdirP} \
            --Rdata {output.Rdata}.P.Rdata \
            --segmentfile {output.segmentfile}.NP.txt \
            --filter {params.filterP}

        Rscript /data/BCI-EvoCa2/marc/anisha/LPWGS-PNP/scripts/QDNAseq.R \
            --bamfiles {input.bams} \
            --binsize {params.binsize} \
            --plotdir {output.plotdir} \
            --Rdata {output.Rdata} \
            --segmentfile {output.segmentfile} \
            --filter ""
        """
