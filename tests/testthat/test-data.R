test_that("subjects", {
  expect_true(is.character(subjects))
  expect_identical(length(subjects), 27L)
})
test_that("example_preprints", {
  expect_true(is.data.frame(example_preprints))
  expect_identical(colnames(example_preprints), c("subject", "title", "url", "abstract", "prompt", "summary"))
})
