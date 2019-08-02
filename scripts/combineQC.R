library(dplyr)
library(readr)
library(tidyr)
library(stringr)
library(argparse)

parser <- ArgumentParser(description = "Parse arguments to combine QC metrics")
parser$add_argument('--WGS', type = 'character',
                    help="List of WGS file metrics", default = NULL, nargs = "+")
parser$add_argument('--insertsize', type = 'character',
                    help="List of WGS file metrics", default = NULL, nargs = "+")
parser$add_argument('--align', type = 'character',
                    help="List of WGS file metrics", default = NULL, nargs = "+")
parser$add_argument('--output', type = 'character',
                    help="List of WGS file metrics")
args <- parser$parse_args()

dfWGS <- data.frame()
for (file in args$WGS){
  print(file)
  metrics <- read.table(file, sep="\t" , header=T)
  samplename = strsplit(file,"metrics")[[1]][1]
  dfWGS <- rbind(dfWGS, metrics %>% mutate(samplename = samplename))
}
print(dfWGS)

dfinsertsize <- data.frame()
for (file in args$insertsize){
  print(file)
  metrics <- read.table(file, sep="\t" , header=T)
  samplename = strsplit(file,"metrics")[[1]][1]
  dfinsertsize <- rbind(dfinsertsize, metrics %>% mutate(samplename = samplename))
}
print(dfinsertsize)

dfalign <- data.frame()
for (file in args$align){
  print(file)
  metrics <- read.table(file, sep="\t" , header=T)
  samplename = strsplit(file,"metrics")[[1]][1]
  dfalign <- rbind(dfalign, metrics %>% mutate(samplename = samplename))
}
print(dfalign)

df <- bind_cols(dfWGS, dfinsertsize, dfalign)

write_csv(df, args$output)
