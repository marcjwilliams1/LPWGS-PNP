calculateBlacklistByRegions <- function(bins, regions) {
#    vmsg("Calculating percent overlap per bin with regions")

    combined <- as.data.frame(regions)

    colnames(combined) <- c("chromosome", "start", "end")
    # Remove chr if present
    combined$chromosome <- sub("^chr", "", combined$chromosome)

    # Remove chromosome not pressent in bin
    combined <- combined[combined$chromosome %in% unique(bins$chromosome), ]

    # Convert XY to number integer
    combined$chromosome[combined$chromosome=="X"] <- "23"
    combined$chromosome[combined$chromosome=="Y"] <- "24"
    combined$chromosome <- as.integer(combined$chromosome)
    combined <- combined[!is.na(combined$chromosome), ]

    bins$chromosome[bins$chromosome=="X"] <- "23"
    bins$chromosome[bins$chromosome=="Y"] <- "24"
    bins$chromosome <- as.integer(bins$chromosome)

    # Assume 1 based coordinate system
    # TODO Check wether necessary

    tmp <- combined$start + 1
    combined$start <- tmp
    combined <- combined[order(combined$chromosome, combined$start), ]

    # Determine binsize
    binSize <- diff(bins$start[1:2])

    # Calculate index, residual,
    # add 1 because it serves as idx
    combined$si <- combined$start %/% binSize + 1
    combined$sm <- binSize - combined$start %% binSize
    # add 1 because it serves as idx
    combined$ei <- combined$end %/% binSize + 1
    combined$em <- combined$end %% binSize
    combined$seDiff <- combined$end - combined$start
    combined$idDiff <- combined$ei - combined$si

    # Calculate continuous IDX
    c(0, cumsum(rle(bins$chromosome)$lengths)) -> chrI
    combined$sI <- combined$si + chrI[ as.integer(combined$chromosome) ]
    combined$eI <- combined$ei + chrI[ as.integer(combined$chromosome) ]

 #   vmsg("Processing partial overlaps")
    # Partial overlaps of segments
    sel1 <- combined$idDiff >= 1
    # Sum complete overlaps eg segment smaller than bin
    sel2 <- combined$idDiff == 0

    aggregate(c(
        combined$sm[sel1],
        combined$em[sel1],
        combined$seDiff[sel2]
    ),
        list(c(
            combined$sI[sel1],
            combined$eI[sel1],
            combined$sI[sel2]
        )
        ), max) -> res12

  #  vmsg("Complete overlaps")
    # Sum complete overlaps of segments eg segment larger than bin
    sel3 <- combined$idDiff > 1
    unlist(sapply(which(sel3), function(x) {
        s <- combined$sI[x] + 1
        e <- combined$eI[x] - 1
        s:e
    })) -> res3

    res <- rbind(res12, data.frame(Group.1 = res3, x = rep(binSize, length(res3))))

    aggregate(res$x, list(res$Group.1), max) -> res

    res$x / binSize * 100 -> res$pct

    blacklist <- rep(0, nrow(bins))
    blacklist[ as.numeric(res$Group.1) ] <- res$pct

    blacklist
}
