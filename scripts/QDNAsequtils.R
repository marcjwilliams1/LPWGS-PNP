getdf <- function(copyNumbersCalled, field = "copynumber", selector = "GC"){
  x <- as.data.frame(copyNumbersCalled@assayData[[field]])
  x <- bind_cols(x, copyNumbersCalled@featureData@data %>% select(chromosome, start, end)) %>%
    mutate(segid = paste(chromosome, start, end, sep = "_")) %>%
    select(chromosome, start, end, segid, everything()) %>%
    gather(key = "sample", value = "segmean", contains("GC"))
  
  return(x)
}

plotCNfrequency <- function(CNbins, plotChr = NULL, CN_low_cutoff = 1.5, CN_high_cutoff = 2.5){
  
  cnfreqplot <- CNbins %>%
    dplyr::select(chromosome, start, end, segmean, sample) %>%
    na.omit() %>%
    as.data.frame(.) %>% #GenVisR doesn't seem to like tibble's
    GenVisR::cnFreq(., genome="hg19",
                    CN_low_cutoff = CN_low_cutoff, CN_high_cutoff = CN_high_cutoff,
                    plotChr = plotChr,
                    CN_Loss_colour = scCN_colors[["CN0"]],
                    CN_Gain_colour = scCN_colors[["CN5"]])
  return(cnfreqplot)
}
# 