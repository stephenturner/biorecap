#' Construct a prompt to summarize a paper
#'
#' @param title The title of the paper.
#' @param abstract The abstract of the paper.
#' @param nsentences The number of sentences to summarize the paper in.
#' @param instructions Instructions to the prompt. This can be a character vector that gets collapsed into a single string.
#'
#' @return A string containing the prompt.
#' @export
#'
#' @examples
#' build_prompt_preprint(title="A great paper", abstract="This is the abstract.")
#'
build_prompt_preprint <- function(title,
                               abstract,
                               nsentences=2L,
                               instructions=c("I am giving you a paper's title and abstract.",
                                              "Summarize the paper in as many sentences as I instruct.",
                                              "Do not include any preamble text to the summary",
                                              "just give me the summary with no preface or intro sentence.")) {
  stopifnot(is.numeric(nsentences) && length(nsentences)==1L && round(nsentences)==nsentences && nsentences>0L)
  instructions <- paste(instructions, collapse=" ")
  prompt <- sprintf("%s\nNumber of sentences in summary: %d\nTitle: %s\nAbstract: %s", instructions, nsentences, title, abstract)
  return(prompt)
}

#' Construct a prompt to summarize a set of papers from a subject
#'
#' @param subject The name of the subject.
#' @param title A character vector of titles in the subject
#' @param summary A character vector of the summaries of the paper provided by [get_preprints()] followed by [add_prompt()] followed by [add_summary()].
#' @param nsentences The number of sentences to summarize the subject in.
#' @param instructions Instructions to the prompt. This can be a character vector that gets collapsed into a single string.
#'
#' @return A string containing the prompt.
#' @export
#'
#' @examples
#' title <- example_preprints |> dplyr::filter(subject=="bioinformatics") |> dplyr::pull(title)
#' summary <- example_preprints |> dplyr::filter(subject=="bioinformatics") |> dplyr::pull(summary)
#' build_prompt_subject(subject="bioinformatics", title=title, summary=summary)
#'
build_prompt_subject <- function(subject,
                                 title,
                                 summary,
                                 nsentences=5L,
                                 instructions=c("I am giving you information about preprints published in bioRxiv recently.",
                                                "I'll give you the subject, preprint titles, and short summary of each paper.",
                                                "Please provide a general summary new advances in this subject/field in general.",
                                                "Provide this summary of the field in as many sentences as I instruct.",
                                                "Do not include any preamble text to the summary",
                                                "just give me the summary with no preface or intro sentence.")) {
  stopifnot(is.numeric(nsentences) && length(nsentences)==1L && round(nsentences)==nsentences && nsentences>0L)
  instructions <- paste(instructions, collapse=" ")
  titlesums <- paste(paste("Title: ", title, "\nSummary: ", summary, sep=""), collapse="\n\n")
  prompt <- sprintf("%s\n\nSubject: %s\nNumber of sentences in summary: %d\n\nHere are the titles and summaries:\n\n%s", instructions, subject, nsentences, titlesums)
  return(prompt)
}

#' Get bioRxiv preprints
#'
#' @param subject A character vector of valid biorxiv subjects. See [subjects].
#' @param baseurl The base URL for the biorxiv RSS feed. Default is `https://connect.biorxiv.org/biorxiv_xml.php?subject=`. Do not change unless you know what you are doing.
#' @param clean Logical; try to strip out graphical abstract information? If TRUE, this strips away any text between `O_FIG` and `C_FIG`, and the words `graphical abstract` from the abstract text in the RSS feed.
#'
#' @return A data frame of bioRxiv preprints.
#' @export
#'
#' @examples
#' preprints <- get_preprints(subject=c("bioinformatics", "genomics"))
#' preprints
#'
get_preprints <- function(subject="all", baseurl="https://connect.biorxiv.org/biorxiv_xml.php?subject=", clean=TRUE) {

  stopifnot(is.character(subject))
  if (any(!subject %in% biorecap::subjects)) stop("Invalid subject. See ?subjects for valid choices.")

  preprints <-
    lapply(subject, \(x) suppressMessages(preprints <- tidyRSS::tidyfeed(paste0(baseurl, x)))) |>
    stats::setNames(subject) |>
    dplyr::bind_rows(.id="subject") |>
    dplyr::select("subject", title="item_title", url="item_link", abstract="item_description") |>
    dplyr::mutate(dplyr::across(dplyr::everything(), trimws))
  if (nrow(preprints)<1L) stop("Something went wrong. No papers found for subject ", subject)

  if (clean) {
    preprints <-
      preprints |>
      dplyr::mutate("abstract"=gsub("(O_FIG.+C_FIG|Graphical abstract|graphic abstract)", "", x=.data$abstract, ignore.case=TRUE))
  }

  class(preprints) <- c("preprints", class(preprints))
  return(preprints)

}

#' Add prompt to a data frame of preprints
#'
#' @param preprints Result from [get_preprints()].
#' @param ... Additional arguments to [build_prompt_preprint()].
#'
#' @seealso [build_prompt_preprint()]
#'
#' @return A data frame of bioRxiv preprints with a prompt added.
#' @export
#'
#' @examples
#' preprints <- get_preprints(subject=c("bioinformatics", "genomics"))
#' preprints <- add_prompt(preprints)
#' preprints
#'
add_prompt <- function(preprints, ...) {

  if(!inherits(preprints, "preprints")) warning("Expecting a data frame of class 'preprints' returned from get_preprints().")
  if (!inherits(preprints, "data.frame")) stop("Expecting a data frame.")
  if (!"title" %in% colnames(preprints)) stop("Expecting a column named 'title' in the data frame.")
  if (!"abstract" %in% colnames(preprints)) stop("Expecting a column named 'abstract' in the data frame.")

  preprints <-
    preprints |>
    dplyr::mutate(prompt=build_prompt_preprint(title=.data$title, abstract=.data$abstract, ...))

  class(preprints) <- c("preprints_prompt", class(preprints))
  return(preprints)

}


#' Generate a summary from a data frame of prompts
#'
#' @param preprints Output from [get_preprints()] followed by [add_prompt()].
#' @param model A model available to Ollama (run `ollamar::list_models()`) to see what's available.
#'
#' @return A tibble, with a response column added.
#' @export
#'
#' @examples
#' \dontrun{
#' # Individual papers
#' preprints <-
#'   get_preprints(c("genomics", "bioinformatics")) |>
#'   add_prompt() |>
#'   add_summary()
#' preprints
#' }
#'
add_summary <- function(preprints, model="llama3.1") {

  if (!inherits(preprints, "preprints_prompt")) warning("Expecting a tibble of class 'preprints_prompt' returned from get_preprints() |> add_prompt().")
  if (!inherits(preprints, "data.frame")) stop("Expecting a data frame.")
  if (!"prompt" %in% colnames(preprints)) stop("Expecting a column named 'prompt' in the data frame.")

  suppressMessages({
    preprints <-
      preprints |>
      dplyr::mutate("summary" = as.vector(sapply(.data$prompt, \(x) ollamar::generate(model=model, prompt=x, output="text")$response)))
  })

  # Remove newlines anywhere within any text
  preprints <-
    preprints |>
    dplyr::mutate(dplyr::across(dplyr::everything(), \(x) trimws(gsub("\n", " ", x))))

  class(preprints) <- c("preprints_summary", class(preprints))
  return(preprints)
}


#' Add prompts for an entire subject
#'
#' @param preprints Output from [get_preprints()] followed by [add_prompt()] followed by [add_summary()].
#' @param ... Additional arguments to [build_prompt_subject()].
#'
#' @return A tibble with a subject and prompt column.
#' @export
#'
#' @examples
#' subjects <-
#'   example_preprints |>
#'   dplyr::group_by(subject) |>
#'   add_prompt_subject()
#' subjects
add_prompt_subject <- function(preprints, ...) {
  if (!inherits(preprints, "preprints_summary")) warning("Expecting a tibble of class 'preprints_prompt' returned from get_preprints() |> add_prompt().")
  if (!inherits(preprints, "data.frame")) stop("Expecting a data frame.")
  if (!all(c("title", "summary") %in% colnames(preprints))) stop("Expecting columns 'title' and 'summary'")
  subjects <-
    preprints |>
    dplyr::group_by(.data$subject) |>
    dplyr::summarize(title=list(.data$title), summary=list(.data$summary)) |>
    dplyr::mutate(prompt=mapply(build_prompt_subject, subject=.data$subject, title=.data$title, summary=.data$summary, ...)) |>
    dplyr::select("subject", "prompt")
  class(subjects) <- c("subjects_prompt", class(subjects))
  return(subjects)
}

#' Create a markdown table from prepreprint summaries
#'
#' @param preprints Output from [get_preprints()] followed by [add_prompt()] followed by [add_summary()].
#' @param cols Columns to display in the resulting markdown table.
#' @param width Vector of relative widths equal to `length(cols)`.
#'
#' @return A tinytable table.
#' @export
#'
#' @examples
#' # Use built-in example data
#' example_preprints
#' tt_preprints(example_preprints[1:2,])
tt_preprints <- function(preprints, cols=c("title", "summary"), width=c(1,3)) {
  if (!inherits(preprints, "preprints_summary")) warning("Expecting a tibble of class 'preprints_summary' returned from get_preprints() |> add_prompt() |> add_summary().")
  if (!inherits(preprints, "data.frame")) stop("Expecting a data frame.")
  if (!all(cols %in% colnames(preprints))) stop("Requested columns not in tibble")
  if (!identical(length(cols), length(width))) stop("Length of cols must equal length of width")
  preprints |>
    dplyr::mutate("title"=sprintf("[%s](%s)", .data$title, .data$url)) |>
    dplyr::select(dplyr::all_of(cols)) |>
    tinytable::tt(width=width) |>
    tinytable::format_tt(markdown=TRUE)
}


#' Create a report from bioRxiv preprints
#'
#' @param output_dir Directory to save the report.
#' @param subject Character vector of subjects to include in the report.
#' @param nsentences Number of sentences to summarize each paper in.
#' @param model The model to use for generating summaries. See [ollamar::list_models()].
#' @param use_example_preprints Use the example preprints data included with the package instead of fetching new data from bioRxiv. For diagnostic/testing purposes only.
#'
#' @return Nothing; called for its side effects to produce a report.
#' @export
#'
#' @examples
#' output_dir <- tempdir()
#' biorecap_report(use_example_preprints=TRUE, output_dir=output_dir)
#' \dontrun{
#' biorecap_report(subject=c("bioinformatics", "genomics", "synthetic_biology"),
#'                 output_dir=output_dir)
#' }
biorecap_report <- function(output_dir=".", subject=NULL, nsentences=2L, model="llama3.1", use_example_preprints=FALSE) {
  skeleton <- system.file("rmarkdown/templates/biorecap/skeleton/skeleton.Rmd", package="biorecap", mustWork = TRUE)
  output_dir <- normalizePath(output_dir)
  output_file <- paste0("biorecap-report-", format(Sys.time(), "%Y-%m-%d-%H%M%S"), ".html")
  if (!use_example_preprints && is.null(subject)) stop("You must provide a subject. See ?subjects.")
  if (tools::file_ext(output_file) != "html") stop("Output file must have an .html extension.")
  rmarkdown::render(input=skeleton,
                    output_file=output_file,
                    output_dir=output_dir,
                    params=list(subject=subject, nsentences=nsentences, model=model, use_example_preprints=use_example_preprints))
}
