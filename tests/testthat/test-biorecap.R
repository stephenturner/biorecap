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
})

