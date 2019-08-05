
rule report:
    input:
        QC="QC/QCresults.csv"
    output:
        report="results/reports/QC.html"
    shell:
        """
        module load singularity
        singularity exec /data/BCI-EvoCa2/marc/singularity/marcjwilliams1-r-tidy-markdown-bio-master-latest.simg \
        Rscript /data/BCI-EvoCa2/marc/anisha/LPWGS-PNP/scripts/report.R \
        --QC {input.QC} \
        --output {output.report}
        """
