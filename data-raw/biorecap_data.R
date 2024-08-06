# Create vector for all bioRxiv subjects ----------------------------------

# https://www.biorxiv.org/alertsrss

subjects <- c("all",
              "animal_behavior_and_cognition",
              "biochemistry",
              "bioengineering",
              "bioinformatics",
              "biophysics",
              "cancer_biology",
              "cell_biology",
              "clinical_trials",
              "developmental_biology",
              "ecology",
              "epidemiology",
              "evolutionary_biology",
              "genetics",
              "genomics",
              "immunology",
              "microbiology",
              "molecular_biology",
              "neuroscience",
              "paleontology",
              "pathology",
              "pharmacology_and_toxicology",
              "plant_biology",
              "scientific_communication_and_education",
              "synthetic_biology",
              "systems_biology",
              "zoology")
usethis::use_data(subjects, overwrite=TRUE)


# Get titles, abstracts, summaries for preprints 2024-08-06 ---------------

library(biorecap)
example_preprints <-
  get_preprints(subject=c("bioinformatics", "genomics", "synthetic_biology")) |>
  add_prompt() |>
  add_summary(model="llama3.1:70b")
usethis::use_data(example_preprints, overwrite=TRUE)
readr::write_csv(example_preprints, here::here("inst/extdata/example_preprints.csv.gz"))
