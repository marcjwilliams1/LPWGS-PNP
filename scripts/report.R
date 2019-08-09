library(tidyverse)
library(rmarkdown)
library(argparse)
library(cowplot)
parser <- ArgumentParser(description = "Parse arguments for QC metrics")
parser$add_argument('--output', type = 'character',
                    help="Output html file")
parser$add_argument('--QC', type = 'character',
                    help="QC file")
parser$add_argument('--CNA', type = 'character',
                    help="CNA file")
parser$add_argument('--plotdir', type = 'character',
                    help="Plotting directory")
parser$add_argument('--readscutoff', type = 'character',
                    help="Cut off to exclude reads from samples")
args <- parser$parse_args()
print(args)

dfQC <- read_csv(args$QC)
CNA <- readRDS(args$CNA)
print(dfQC)
print(typeof(args$readscutoff))

render("/data/BCI-EvoCa2/marc/anisha/LPWGS-PNP/scripts/report.Rmd",
    "html_document",
    output_dir = dirname(args$output),
    output_file = basename(args$output),
    intermediates_dir = dirname(args$output),
    clean = FALSE,
    params = list(dfQC = dfQC, CNA = CNA, plotdir = args$plotdir, readscutoff = args$readscutoff))
