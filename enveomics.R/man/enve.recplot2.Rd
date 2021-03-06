% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/recplot2.R
\name{enve.recplot2}
\alias{enve.recplot2}
\title{Enveomics: Recruitment Plot (2)}
\usage{
enve.recplot2(prefix, plot = TRUE, pos.breaks = 1000,
  pos.breaks.tsv = NA, id.breaks = 60, id.free.range = FALSE,
  id.metric = c("identity", "corrected identity", "bit score"),
  id.summary = sum, id.cutoff = 95, threads = 2, verbose = TRUE,
  ...)
}
\arguments{
\item{prefix}{Path to the prefix of the \code{BlastTab.catsbj.pl} output files. At
least the files .rec and .lim must exist with this prefix.}

\item{plot}{Should the object be plotted?}

\item{pos.breaks}{Breaks in the positions histogram. It can also be a vector of break
points, and values outside the range are ignored. If zero (0), it
uses the sequence breaks as defined in the .lim file, which means
one bin per contig (or gene, if the mapping is agains genes). Ignored
if `pos.breaks.tsv` is passed.}

\item{pos.breaks.tsv}{Path to a list of (absolute) coordinates to use as position breaks.
This tab-delimited file can be produced by \code{GFF.catsbj.pl}, and it
must contain at least one column: coordinates of the break positions of
each position bin. If it has a second column, this is used as the name
of the position bin that ends at the given coordinate (the first row is
ignored). Any additional columns are currently ignored. If \code{NA},
position bins are determined by \code{pos.breaks}.}

\item{id.breaks}{Breaks in the identity histogram. It can also be a vector of break
points, and values outside the range are ignored.}

\item{id.free.range}{Indicates that the range should be freely set from the observed
values. Otherwise, 70-100\% is included in the identity histogram
(default).}

\item{id.metric}{Metric of identity to be used (Y-axis). Corrected identity is only
supported if the original BLAST file included sequence lengths.}

\item{id.summary}{Function summarizing the identity bins. Other recommended options
include: \code{median} to estimate the median instead of total bins, and
\code{function(x) mlv(x,method='parzen')$M} to estimate the mode.}

\item{id.cutoff}{Cutoff of identity metric above which the hits are considered
\code{in-group}. The 95\% identity corresponds to the expectation of
ANI<95\% within species.}

\item{threads}{Number of threads to use.}

\item{verbose}{Indicates if the function should report the advance.}

\item{...}{Any additional parameters supported by \code{\link{plot.enve.RecPlot2}}.}
}
\value{
Returns an object of class \code{\link{enve.RecPlot2}}.
}
\description{
Produces recruitment plots provided that \code{BlastTab.catsbj.pl} has
been previously executed.
}
\author{
Luis M. Rodriguez-R [aut, cre]

Kenji Gerhardt [aut]
}
