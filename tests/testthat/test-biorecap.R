test_that("build_prompt_preprint", {
  expect_silent(res <- build_prompt_preprint(title="A great paper", abstract="This is the abstract."))
  expect_true(is.character(res))
  expect_error(build_prompt_preprint(title="A great paper", abstract="This is the abstract.", nsentences=0))
})

test_that("get_preprints", {
  expect_silent(preprints <- get_preprints(subject="all"))
  expect_true(inherits(preprints, "preprints"))
  expect_true(inherits(preprints, "tbl"))
  expect_error(get_preprints(subject=123))
  expect_error(get_preprints(subject="invalid"))
})

test_that("add_prompt", {
  expect_silent(res <- add_prompt(example_preprints))
  expect_true(inherits(res, "preprints_prompt"))
  expect_true(inherits(res, "tbl"))
  expect_error(expect_warning(add_prompt(iris)))
  expect_error(add_prompt("invalid"))
  expect_warning(add_prompt(data.frame(title=character(), abstract=character())))
  expect_error(add_prompt(data.frame(title=character())))
  expect_error(add_prompt(data.frame(abstract=character())))
})

test_that("add_summary", {
  expect_error(expect_warning(add_summary(data.frame())))
  expect_warning(add_summary(data.frame(prompt=character())))
  expect_silent(add_summary(structure(data.frame(prompt=character()), class=c("preprints_prompt", "data.frame"))))
})

test_that("tt_preprints", {
  expect_silent(res <- tt_preprints(example_preprints[1:2,]))
  expect_true(inherits(res, "tinytable"))
})

test_that("tt_preprints", {
  skip_on_ci()
  output_dir <- tempdir()
  expect_silent(biorecap_report(use_example_preprints=TRUE, output_dir=output_dir, quiet=TRUE))
  expect_error(biorecap_report(use_example_preprints=FALSE, output_dir=output_dir))
})


