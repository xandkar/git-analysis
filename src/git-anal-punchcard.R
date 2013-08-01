#! /usr/bin/env Rscript
# vim: filetype=r:

ParseTimestamps <- function(timestamps) {
  # Example timestamp: "Tue Nov 6 21:28:48 2012 -0500"
  #
  # Using relative timestamps literally instead of converting with as.POSIXct,
  # because commits could've been made from several timezones, in which case I
  # think it is more interesting to see the time as perceived by the committer
  # rather than a globally normalized time.
  components <- matrix(unlist(strsplit(timestamps, " +")), ncol=6, byrow=TRUE)
  days       <- components[,1]
  times      <- components[,4]
  hours      <- matrix(unlist(strsplit(times, ":")), ncol=3, byrow=TRUE)[,1]
  list( days  = days
      , hours = hours
      )
}

ParseLines <- function(lines) {
  # Example log line: "Tue Nov 6 21:28:48 2012 -0500|Jeff Lebowski"
  line.comps <- strsplit(lines, "\\|")

  # Drop lines with missing data (most likely names)
  line.comps.lengths <- lapply(line.comps, length)
  line.comps <- line.comps[line.comps.lengths == 2]

  log.data  <- matrix(unlist(line.comps), ncol=2, byrow=T)
  log.times <- ParseTimestamps(log.data[,1])
  log.names <- log.data[,2]
  all.days  <- c("Sun", "Sat", "Fri", "Thu", "Wed", "Tue", "Mon")
  all.hours <- 0:23
  data.frame( Day  = factor(log.times$days , levels=all.days)
            , Hour = factor(log.times$hours, levels=all.hours)
            , Name = log.names
            )
}

GetTopCommitters <- function(data, n=4) {
  names(sort(table(data$Name), decreasing=TRUE))[1:n]
}

PlotPunchcard <- function(data, byname=FALSE) {
  p <-
    ( ggplot2::ggplot(data, ggplot2::aes(y=Day, x=Hour))
    + ggplot2::geom_point(ggplot2::aes(size=Freq))
    + ggplot2::scale_size(range=c(0, 10))
    )
  if (byname)
    p + ggplot2::facet_wrap(~ Name, ncol=1)
  else
    p
}

Main <- function() {
  args <- commandArgs(trailingOnly=TRUE)
  n.top.committers <- if (length(args) > 0) args[1] else 0
  log.lines <- system("git log --format='%ad|%an'", intern=TRUE)
  log.data  <- ParseLines(log.lines)
  punchcard.tbl  <- as.data.frame(table(log.data))
  punchcard.plot <- (
    if (n.top.committers > 0) {
      top.committers <- GetTopCommitters(log.data, n.top.committers)
      punchcard.tbl <- punchcard.tbl[punchcard.tbl$Name %in% top.committers,]
      PlotPunchcard(punchcard.tbl, byname=TRUE)
    }
    else {
      PlotPunchcard(punchcard.tbl)
    }
  )
  ggplot2::ggsave( filename = "punchcard.png"
                 , plot     = punchcard.plot
                 , width    = 10
                 , height   = 5
                 )
}

Main()
