% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/recplot2.R
\name{enve.recplot2.coordinates}
\alias{enve.recplot2.coordinates}
\title{Enveomics: Recruitment Plot (2) Coordinates}
\usage{
enve.recplot2.coordinates(x, bins)
}
\arguments{
\item{x}{\code{\link{enve.RecPlot2}} object.}

\item{bins}{Vector of selected bins to return. It can be a vector of logical values
with the same length as \code{x$pos.breaks-1} or a vector of integers. If
missing, returns the coordinates of all windows.}
}
\value{
Returns a data.frame with five columns: \code{name.from} (character),
\code{pos.from} (numeric), \code{name.to} (character), \code{pos.to}
(numeric), and \code{seq.name} (character).
The first two correspond to sequence and position of the start point of the
bin. The next two correspond to the sequence and position of the end point of
the bin. The last one indicates the name of the sequence (if defined).
}
\description{
Returns the sequence name and coordinates of the requested position bins.
}
\author{
Luis M. Rodriguez-R [aut, cre]
}
