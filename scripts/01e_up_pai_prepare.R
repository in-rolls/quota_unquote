# Profile PAI and prepare the Uttar Pradesh GP-theme table.
# Output: data/pai/pai_gp_up_2022_2024.parquet,
#         data/pai/pai_profile_up.csv

library(arrow)
library(dplyr)
library(here)
library(readr)

source(here("scripts", "00_config.R"))
source(here("scripts", "00_utils.R"))

message("Reading PAI metadata for Uttar Pradesh")
metadata <- read_csv(
    resolve_pai_file("gp_metadata.csv"),
    col_select = c(
        year, state, district, district_value, block, block_value, gp_name, gp_code
    ),
    col_types = cols(.default = col_character()),
    na = "",
    show_col_types = FALSE
) |>
    filter(.data$state == STATE_UP) |>
    mutate(gp_code = na_if(.data$gp_code, ""))

assert_unique(metadata, c("year", "district", "block", "gp_name"), "UP PAI metadata")

message("Reading PAI scores for Uttar Pradesh")
scores <- read_csv(
    resolve_pai_file("gp_scores_long.csv"),
    col_select = c(
        year, state, district, district_value, block, block_value, gp_name, gp_code,
        theme_header, theme_slug, score, grade, band
    ),
    col_types = cols(
        .default = col_character(),
        score = col_double()
    ),
    na = "",
    show_col_types = FALSE
) |>
    filter(.data$state == STATE_UP) |>
    mutate(
        gp_code = na_if(.data$gp_code, ""),
        district_std = normalize_name(.data$district),
        block_std = normalize_name(.data$block),
        gp_name_std = normalize_name(.data$gp_name),
        pai_row_key = paste(
            .data$year, .data$district_value, .data$block_value,
            .data$gp_name_std, sep = "__"
        )
    )

assert_unique(
    scores,
    c("year", "district", "block", "gp_name", "theme_slug"),
    "UP PAI scores"
)
if (!PAI_T8_SLUG %in% scores$theme_slug) {
    stop("The stable PAI Good Governance slug is absent for UP", call. = FALSE)
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

expected_rows <- c("2022-2023" = 20768L, "2023-2024" = 35979L)
observed_rows <- setNames(profile$rows, profile$year)
if (!identical(observed_rows[names(expected_rows)], expected_rows)) {
    stop("UP PAI row counts differ from the profiled source", call. = FALSE)
}

write_parquet_receipt(scores, here("data", "pai", "pai_gp_up_2022_2024.parquet"))
write_csv_receipt(profile, here("data", "pai", "pai_profile_up.csv"))
