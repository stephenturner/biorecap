% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/biorecap.R
\name{build_prompt_subject}
\alias{build_prompt_subject}
\title{Construct a prompt to summarize a set of papers from a subject}
\usage{
build_prompt_subject(
  subject,
  title,
  summary,
  nsentences = 5L,
  instructions = c("I am giving you information about recent bioRxiv/medRxiv preprints.",
    "I'll give you the subject, preprint titles, and short summary of each paper.",
    "Please provide a general summary new advances in this subject/field in general.",
    "Provide this summary of the field in as many sentences as I instruct.",
    "Do not include any preamble text to the summary",
    "just give me the summary with no preface or intro sentence.")
)
}
\arguments{
\item{subject}{The name of the subject.}

\item{title}{A character vector of titles in the subject}

\item{summary}{A character vector of the summaries of the paper provided by \code{\link[=get_preprints]{get_preprints()}} followed by \code{\link[=add_prompt]{add_prompt()}} followed by \code{\link[=add_summary]{add_summary()}}.}

\item{nsentences}{The number of sentences to summarize the subject in.}

\item{instructions}{Instructions to the prompt. This can be a character vector that gets collapsed into a single string.}
}
\value{
A string containing the prompt.
}
\description{
Construct a prompt to summarize a set of papers from a subject
}
\examples{
title <- example_preprints |> dplyr::filter(subject=="bioinformatics") |> dplyr::pull(title)
summary <- example_preprints |> dplyr::filter(subject=="bioinformatics") |> dplyr::pull(summary)
build_prompt_subject(subject="bioinformatics", title=title, summary=summary)

}
