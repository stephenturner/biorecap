# Create vector for all bioRxiv subjects ----------------------------------

subjects <- list()

# https://www.biorxiv.org/alertsrss
subjects$biorxiv <- c("all",
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

# https://www.medrxiv.org/content/alertsrss
subjects$medrxiv <- c("all",
                      "Addiction_Medicine",
                      "Allergy_and_Immunology",
                      "Anesthesia",
                      "Cardiovascular_Medicine",
                      "Dentistry_and_Oral_Medicine",
                      "Dermatology",
                      "Emergency_Medicine",
                      "endocrinology",
                      "Epidemiology",
                      "endocrinology",
                      "epidemiology",
                      "Forensic_Medicine",
                      "Gastroenterology",
                      "Genetic_and_Genomic_Medicine",
                      "Geriatric_Medicine",
                      "Health_Economics",
                      "Health_Informatics",
                      "Health_Policy",
                      "Health_Systems_and_Quality_Improvement",
                      "Hematology",
                      "hivaids",
                      "infectious_diseases",
                      "Intensive_Care_and_Critical_Care_Medicine",
                      "Medical_Education",
                      "Medical_Ethics",
                      "Nephrology",
                      "Neurology",
                      "Nursing",
                      "Nutrition",
                      "Obstetrics_and_Gynecology",
                      "Occupational_and_Environmental_Health",
                      "Oncology",
                      "Ophthalmology",
                      "Orthopedics",
                      "Otolaryngology",
                      "Pain_Medicine",
                      "Palliative_Medicine",
                      "Pathology",
                      "Pediatrics",
                      "Pharmacology_and_Therapeutics",
                      "Primary_Care_Research",
                      "Psychiatry_and_Clinical_Psychology",
                      "Public_and_Global_Health",
                      "Radiology_and_Imaging",
                      "Rehabilitation_Medicine_and_Physical_Therapy",
                      "Respiratory_Medicine",
                      "Rheumatology",
                      "Sexual_and_Reproductive_Health",
                      "Sports_Medicine",
                      "Surgery",
                      "Toxicology",
                      "Transplantation",
                      "Urology")

subjects <- lapply(subjects, tolower)
usethis::use_data(subjects, overwrite=TRUE)


# Get titles, abstracts, summaries for preprints 2024-09-25 ---------------

library(biorecap)
example_preprints <-
  get_preprints(subject=c("bioinformatics", "infectious_diseases")) |>
  add_prompt() |>
  add_summary(model="llama3.2")
usethis::use_data(example_preprints, overwrite=TRUE)
readr::write_csv(example_preprints, here::here("inst/extdata/example_preprints.csv.gz"))
