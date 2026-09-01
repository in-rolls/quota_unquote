# 01a_pai_prepare.R
# Profile PAI and prepare the Rajasthan GP-theme table.
# Output: data/pai/pai_gp_raj_2022_2024.parquet,
#         data/pai/pai_profile_raj.csv

library(here)
library(dplyr)
library(readr)
library(arrow)

source(here("scripts", "00_config.R"))
source(here("scripts", "00_utils.R"))

message("Reading PAI metadata")
metadata <- read_csv(
    resolve_pai_file("gp_metadata.csv"),
    col_select = c(
        year, state, district, district_value, block, block_value, gp_name, gp_code
    ),
    col_types = cols(
        year = col_character(),
        state = col_character(),
        district = col_character(),
        district_value = col_character(),
        block = col_character(),
        block_value = col_character(),
        gp_name = col_character(),
        gp_code = col_character()
    ),
    na = "",
    show_col_types = FALSE
) |>
    filter(.data$state == STATE_PRIMARY) |>
    mutate(gp_code = na_if(.data$gp_code, ""))

assert_unique(metadata, c("year", "district", "block", "gp_name"), "PAI metadata")

message("Reading PAI scores")
scores <- read_csv(
    resolve_pai_file("gp_scores_long.csv"),
    col_select = c(
        year, state, district, district_value, block, block_value, gp_name, gp_code,
        theme_header, theme_slug, score, grade, band
    ),
    col_types = cols(
        year = col_character(),
        state = col_character(),
        district = col_character(),
        district_value = col_character(),
        block = col_character(),
        block_value = col_character(),
        gp_name = col_character(),
        gp_code = col_character(),
        theme_header = col_character(),
        theme_slug = col_character(),
        score = col_double(),
        grade = col_character(),
        band = col_character()
    ),
    na = "",
    show_col_types = FALSE
) |>
    filter(.data$state == STATE_PRIMARY) |>
    mutate(
        gp_code = na_if(.data$gp_code, ""),
        district_std = normalize_name(.data$district),
        block_std = normalize_name(.data$block),
        gp_name_std = normalize_name(.data$gp_name),
        pai_row_key = paste(.data$year, .data$district_value, .data$block_value, .data$gp_name_std, sep = "__")
    )

assert_unique(
    scores,
    c("year", "district", "block", "gp_name", "theme_slug"),
    "PAI scores"
)

if (!PAI_T8_SLUG %in% scores$theme_slug) {
    stop("The stable PAI Good Governance slug is absent", call. = FALSE)
}

profile <- metadata |>
    group_by(.data$year) |>
    summarise(
        rows = n(),
        districts = n_distinct(.data$district),
        blocks = n_distinct(.data$district, .data$block),
        unique_name_keys = n_distinct(.data$district, .data$block, .data$gp_name),
        gp_code_nonmissing = sum(!is.na(.data$gp_code)),
        unique_gp_codes = n_distinct(.data$gp_code, na.rm = TRUE),
        .groups = "drop"
    )

expected_rows <- c("2022-2023" = 10634L, "2023-2024" = 11037L)
observed_rows <- setNames(profile$rows, profile$year)
if (!identical(observed_rows[names(expected_rows)], expected_rows)) {
    stop("Rajasthan PAI row counts differ from the profiled source", call. = FALSE)
}

write_parquet_receipt(scores, here("data", "pai", "pai_gp_raj_2022_2024.parquet"))
write_csv_receipt(profile, here("data", "pai", "pai_profile_raj.csv"))
