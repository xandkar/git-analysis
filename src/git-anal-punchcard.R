#! /usr/bin/env Rscript
# vim: filetype=r:

DATA.DIR <- ".git-anal"


ParseTimestamps <- function(timestamps) {
  # Example timestamp: "Tue Nov 6 21:28:48 2012 -0500"
  #
  # Using relative timestamps literally instead of converting with as.POSIXct,
  # because commits could've been made from several timezones, in which case I
  # think it is more interesting to see the time as perceived by the committer
  # rather than a globally normalized time.
  components <- matrix(unlist(strsplit(timestamps, " +")), ncol=6, byrow=TRUE)
  days       <- components[, 1]
  times      <- components[, 4]
  hours      <- matrix(unlist(strsplit(times, ":")), ncol=3, byrow=TRUE)[, 1]
  list( days  = days
      , hours = as.numeric(hours)
      )
}


DashesToZeros <- function(v) {
  ifelse(v == "-", 0, v)
}


MsgFlatten <- function(msg) {
  len <- length(msg)
  head <- msg[1]
  if (len > 1) {
    edits <- msg[2:len]
    edits <- matrix(unlist(strsplit(edits, "\t")), ncol=3, byrow=TRUE)
    insertions <- as.numeric(DashesToZeros(edits[, 1]))
    deletions  <- as.numeric(DashesToZeros(edits[, 2]))
    total.insertions <- sum(insertions)
    total.deletions  <- sum(deletions)
    paste(c(head, total.insertions, total.deletions), collapse="|")
  } else {
    paste(c(head, 0, 0), collapse="|")
  }
}


ExtractMsgs <- function(lines) {
  msg.start.indices <- grep("^[A-Z]", lines)
  msg.range.indices <- list()
  num.msgs  <- length(msg.start.indices)
  num.lines <- length(lines)
  for (i in 1:num.msgs) {
    range <- (
      if (i == num.msgs) {
        msg.start.indices[i]:num.lines
      } else {
        msg.start.indices[i]:(msg.start.indices[i+1] - 1)
      }
    )
    msg.range.indices[[i]] <- range
  }
  msgs <- lapply(msg.range.indices, function(indices) lines[indices])
  msgs <- lapply(msgs, MsgFlatten)
  unlist(msgs)
}


ParseLog <- function(lines) {
  # Example log lines:
  #   Tue Nov 6 21:28:48 2012 -0500|Jeff Lebowski
  #   0\t3\tsrc/foo_bar.erl
  #   1\t4\tsrc/foo_baz.erl
  #   14\t15\tREADME.md
  #   Tue Nov 5 17:01:27 2012 -0700|Walter Sobchak
  #   -\t-\tbin/blob
  #   2\t4\tsrc/foo_year.erl
  #
  # Will be extracted as:
  #   Tue Nov 6 21:28:48 2012 -0500|Jeff Lebowski|1|7
  #   Tue Nov 5 17:01:27 2012 -0700|Walter Sobchak|2|4

  number.of.msg.fields <- 4

  msgs       <- ExtractMsgs(lines)
  msg.fields <- strsplit(msgs, "\\|")

  # Drop lines with missing data (most likely names)
  msg.comps.lengths <- lapply(msg.fields, length)
  msg.fields <- msg.fields[msg.comps.lengths == number.of.msg.fields]

  log.data  <- matrix(unlist(msg.fields), ncol=number.of.msg.fields, byrow=T)
  log.times <- ParseTimestamps(log.data[, 1])

  all.days  <- c("Sun", "Sat", "Fri", "Thu", "Wed", "Tue", "Mon")
  all.hours <- 0:23

  data.frame( Day  = factor(log.times$days , levels=all.days)
            , Hour = factor(log.times$hours, levels=all.hours)
            , Name = factor(log.data[, 2])
            , Insertions = as.numeric(log.data[, 3])
            , Deletions  = as.numeric(log.data[, 4])
            )
}


GetTopCommitters <- function(data, n=4) {
  names(sort(table(data$Name), decreasing=TRUE))[1:n]
}


PlotPunchcard <- function( data
                         , is.by.name    = FALSE
                         , is.show.diff  = FALSE
                         , is.show.edits = FALSE
                         ) {
  punchcard.plot <-
    ( ggplot2::ggplot(data, ggplot2::aes(y=Day, x=Hour))
    + ggplot2::geom_point(ggplot2::aes(size=Freq))
    + ggplot2::scale_size(range=c(0, 10))
    )

  punchcard.plot <-
    if (is.by.name) {
      ( punchcard.plot
      + ggplot2::facet_wrap(~ Name, ncol=1)
      )
    } else {
      punchcard.plot
    }

  punchcard.plot <-
    if (is.show.diff & !is.show.edits) {
      ( punchcard.plot
      + ggplot2::aes(color=Diff)
      + ggplot2::scale_colour_gradient2( low=scales::muted("red")
                                       , high=scales::muted("green")
                                       )
      )
    } else if (!is.show.diff & is.show.edits) {
      ( punchcard.plot
      + ggplot2::aes(color=Edits)
      )
    } else {
      punchcard.plot
    }

  punchcard.plot
}


LookupEdits <- function(tbl.row, log.data) {
  log.data <- log.data[ log.data$Day  == tbl.row[1]
                      & log.data$Hour == tbl.row[2]
                      & log.data$Name == tbl.row[3]
                      ,
                      ]
  if (nrow(log.data) > 0) {
    c( sum(log.data$Insertions)
     , sum(log.data$Deletions)
     )
  } else {
    c(0, 0)
  }
}


FetchLog <- function() {
  command <- "git log --format='%ad|%an' --numstat | grep -v '^$'"
  system(command, intern=TRUE)
}


GetOpts <- function() {
  args <- commandArgs(trailingOnly=TRUE)

  indices.nums <- grep("^[0-9]+$", args)
  indices.diff <- grep("^diff$", args)
  indices.edits <- grep("^edits$", args)

  diff.or.edits <- (
    if ((length(indices.diff) > 0) & (length(indices.edits) > 0)) {
      # Last-specified wins:
      args[max(max(indices.diff), max(indices.edits))]
    } else if ((length(indices.diff) > 0) & !(length(indices.edits) > 0)) {
      "diff"
    } else if (!(length(indices.diff) > 0) & (length(indices.edits) > 0)) {
      "edits"
    } else {
      "NEITHER"
    }
  )

  n.top.committers <- (
    if (length(indices.nums) > 0) {
      args[indices.nums[1]]
    } else {
      0
    }
  )

  list( n.top.committers = n.top.committers
      , is.show.diff     = if (diff.or.edits == "diff")  TRUE else FALSE
      , is.show.edits    = if (diff.or.edits == "edits") TRUE else FALSE
      )
}


Main <- function() {
  opts <- GetOpts()
  log.data <- ParseLog(FetchLog())

  # Leave-out edits columns from frquency count
  punchcard.tbl <- as.data.frame(table(log.data[, 1:3]))

  punchcard.tbl <- (
    # Re-inserting the edit data is very expensive, so we're better off
    # avoiding it unless explicitly asked to
    if (opts$is.show.diff | opts$is.show.edits) {
      # The following call to "apply" was 84% of the cost, accodrding to Rprof
      edits <- apply(punchcard.tbl, 1, LookupEdits, log.data)
      insertions <- edits[1, ]
      deletions  <- edits[2, ]
      punchcard.tbl$Diff  <- insertions - deletions
      punchcard.tbl$Edits <- insertions + deletions
      punchcard.tbl
    } else {
      punchcard.tbl
    }
  )

  punchcard.plot <- (
    if (opts$n.top.committers > 0) {
      top.committers <- GetTopCommitters(log.data, opts$n.top.committers)
      punchcard.tbl <- punchcard.tbl[punchcard.tbl$Name %in% top.committers, ]
      PlotPunchcard( punchcard.tbl
                   , is.by.name    = TRUE
                   , is.show.diff  = opts$is.show.diff
                   , is.show.edits = opts$is.show.edits
                   )
    } else {
      PlotPunchcard( punchcard.tbl
                   , is.show.diff  = opts$is.show.diff
                   , is.show.edits = opts$is.show.edits
                   )
    }
  )

  dir.create(DATA.DIR, showWarnings=FALSE)

  ggplot2::ggsave( filename = file.path(DATA.DIR, "punchcard.png")
                 , plot     = punchcard.plot
                 , width    = 10
                 , height   = 5
                 )
  write.csv(punchcard.tbl, file=file.path(DATA.DIR, "punchcard.csv"))
  write.csv(log.data     , file=file.path(DATA.DIR, "log.csv"))
}


Main()
