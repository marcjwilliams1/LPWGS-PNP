
rule report:
    input:
        QC="QC/QCresults.csv",
        CNA="CNcalling/finalresults." + config["binsize"] + ".Rdata"
    output:
        report="reports/results.html",
        plotdir=directory(config["workdirectory"] + "reports/plots/")
    params:
        readscutoff=config["readscutoff"],
        singularityimage=config["singularityR"],
        pipelinedirectory=config["pipelinedirectory"]
    shell:
        """
        #mkdir {output.plotdir}
        module load singularity
        singularity exec {params.singularityimage} \
        Rscript {params.pipelinedirectory}/scripts/report.R \
            --QC {input.QC} \
            --output {output.report} \
            --CNA {input.CNA} \
            --plotdir {output.plotdir} \
            --pipelinedirectory {params.pipelinedirectory} \
            --readscutoff {params.readscutoff}
        """
