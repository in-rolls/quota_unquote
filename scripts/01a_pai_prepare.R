# 01a_pai_prepare.R
# Prepare the Rajasthan GP-theme table from the pinned PAI release.
# Output: data/pai/pai_gp_raj_2022_2024.parquet,
#         data/pai/pai_profile_raj.csv

library(here)
library(dplyr)
library(arrow)

source(here("scripts", "00_config.R"))
source(here("scripts", "00_utils.R"))

message("Reading the PAI release for Rajasthan")
scores <- read_pai_state_long(STATE_PRIMARY)

assert_unique(scores, c("year", "gp_code", "theme_slug"), "Rajasthan PAI scores")
assert_unique(
    scores,
    c("year", "district", "block", "gp_name", "theme_slug"),
    "Rajasthan PAI name keys"
)
if (!PAI_T8_SLUG %in% scores$theme_slug) {
    stop("The stable PAI Good Governance slug is absent for Rajasthan", call. = FALSE)
}
if (any(is.na(scores$gp_code))) {
    stop("Every scored Rajasthan PAI row must carry an LGD GP code", call. = FALSE)
}

profile <- scores |>
    filter(.data$theme_slug == PAI_T8_SLUG) |>
    group_by(.data$year) |>
    summarise(
        rows = n(),
        districts = n_distinct(.data$district),
        blocks = n_distinct(.data$district, .data$block),
        unique_name_keys = n_distinct(.data$district, .data$block, .data$gp_name),
        gp_code_nonmissing = sum(!is.na(.data$gp_code)),
        unique_gp_codes = n_distinct(.data$gp_code, na.rm = TRUE),
        t8_scored = sum(!is.na(.data$score)),
        .groups = "drop"
    )

expected_rows <- c("2022-2023" = 10634L, "2023-2024" = 11037L)
observed_rows <- setNames(profile$rows, profile$year)
if (!identical(observed_rows[names(expected_rows)], expected_rows)) {
    stop("Rajasthan PAI scored-GP counts differ from the pinned release", call. = FALSE)
}

write_parquet_receipt(scores, here("data", "pai", "pai_gp_raj_2022_2024.parquet"))
write_csv_receipt(profile, here("data", "pai", "pai_profile_raj.csv"))
