library(tidyverse)
library(rmarkdown)
library(argparse)
library(cowplot)
parser <- ArgumentParser(description = "Parse arguments for QC metrics")
parser$add_argument('--output', type = 'character',
                    help="Output html file")
parser$add_argument('--QC', type = 'character',
                    help="QC file")
args <- parser$parse_args()

dfQC <- read_csv(args$QC)
print(dfQC)

render("/data/BCI-EvoCa2/marc/anisha/LPWGS-PNP/scripts/report.Rmd",
    "html_document",
    output_dir = dirname(args$output),
    output_file = basename(args$output),
    intermediates_dir = dirname(args$output),
    clean = FALSE,
    params = list(dfQC = dfQC))
