test_that("subjects", {
  expect_true(is.list(subjects))
  expect_true(is.character(subjects$biorxiv))
  expect_identical(length(subjects$biorxiv), 27L)
  expect_true(is.character(subjects$medrxiv))
  expect_identical(length(subjects$medrxiv), 54L)
})
test_that("example_preprints", {
  expect_true(is.data.frame(example_preprints))
  expect_identical(colnames(example_preprints), c("source", "subject", "title", "url", "abstract", "prompt", "summary"))
})
