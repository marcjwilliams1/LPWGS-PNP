
rule report:
    input:
        QC="QC/QCresults.csv",
        CNA="CNcalling/finalresults." + config["binsize"] + ".Rdata"
    output:
        report="reports/results.html",
        plotdir=directory(config["workdirectory"] + "reports/plots/")
    shell:
        """
        #mkdir {output.plotdir}
        module load singularity
        singularity exec /data/BCI-EvoCa2/marc/singularity/marcjwilliams1-r-tidy-markdown-bio-master-latest.simg \
        Rscript /data/BCI-EvoCa2/marc/anisha/LPWGS-PNP/scripts/report.R \
        --QC {input.QC} \
        --output {output.report} \
        --CNA {input.CNA} \
        --plotdir {output.plotdir}
        """
