rule CNcalling:
    input:
        bams=expand("bams/3.final/{sample}.bam", sample = SAMPLES)
    output:
        Rdata="CNcalling/finalresults." + config["binsize"] + ".Rdata",
        segmentfile="CNcalling/finalresults." + config["binsize"] + ".segments.txt",
        plotdir=directory("CNcalling/plots/binsize" + config["binsize"])
    threads: 1
    params: binsize=config["binsize"]
    shell:
        """
        module load R
        Rscript /data/BCI-EvoCa2/marc/anisha/LPWGS-PNP/scripts/QDNAseq.R \
            --bamfiles {input.bams} \
            --binsize {params.binsize} \
            --plotdir {output.plotdir} \
            --Rdata {output.Rdata} \
            --segmentfile {output.segmentfile}
        """
