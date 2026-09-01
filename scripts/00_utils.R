# 00_utils.R
# Source resolution, integrity checks, and reusable transformations.
# Output: none

manifest <- function() {
    yaml::read_yaml(here::here("data", "manifest.yaml"))
}

verify_sha256 <- function(path, expected) {
    if (!file.exists(path)) {
        stop("Missing source file: ", path, call. = FALSE)
    }
    actual <- digest::digest(path, algo = "sha256", file = TRUE)
    if (!identical(actual, expected)) {
        stop(
            "Source hash mismatch for ", path, "\n",
            "expected: ", expected, "\n",
            "actual:   ", actual,
            call. = FALSE
        )
    }
    invisible(path)
}

resolve_pai_file <- function(filename) {
    spec <- manifest()$upstream$pai
    explicit_dir <- Sys.getenv("PAI_DATA_DIR", unset = "")
    candidates <- c(
        if (nzchar(explicit_dir)) file.path(path.expand(explicit_dir), filename),
        file.path(spec$sibling, "data", filename)
    )
    candidates <- candidates[file.exists(candidates)]
    if (length(candidates) == 0L) {
        stop(
            "Cannot find ", filename, ". Set PAI_DATA_DIR to a directory containing ",
            "the consolidated PAI indexes. Rebuild them with ../pai/scripts/",
            "pai_rebuild_index.py or extract the Dataverse release.",
            call. = FALSE
        )
    }
    path <- normalizePath(candidates[[1]], mustWork = TRUE)
    verify_sha256(path, spec$files[[filename]])
    path
}

resolve_quota_raj_panel <- function() {
    spec <- manifest()$upstream$quota_raj
    rel <- "data/raj/shrug_gp_raj_15_20_block.parquet"
    explicit <- Sys.getenv("QUOTA_RAJ_PANEL", unset = "")
    path <- if (nzchar(explicit)) path.expand(explicit) else file.path(spec$sibling, rel)
    path <- normalizePath(path, mustWork = TRUE)
    verify_sha256(path, spec$files[[rel]])
    path
}

resolve_up_election_file <- function() {
    spec <- manifest()$upstream$local_elections_up
    rel <- "data/fin/up_gp_elections_standardized.parquet"
    explicit <- Sys.getenv("UP_ELECTION_FILE", unset = "")
    path <- if (nzchar(explicit)) path.expand(explicit) else file.path(spec$sibling, rel)
    path <- normalizePath(path, mustWork = TRUE)
    verify_sha256(path, spec$files[[rel]])
    path
}

normalize_name <- function(x) {
    x <- stringi::stri_trans_general(x, "Latin-ASCII")
    x <- stringi::stri_trans_tolower(x)
    x <- gsub("[^[:alnum:]]+", " ", x)
    x <- trimws(x)
    gsub("[[:space:]]+", " ", x)
}

assert_unique <- function(data, columns, label) {
    duplicates <- data |>
        dplyr::count(dplyr::across(dplyr::all_of(columns)), name = "n") |>
        dplyr::filter(.data$n > 1L)
    if (nrow(duplicates) > 0L) {
        stop(label, " is not unique on ", paste(columns, collapse = " + "), call. = FALSE)
    }
    invisible(data)
}

assert_binary <- function(x, label) {
    values <- sort(unique(stats::na.omit(x)))
    if (!identical(values, c(0L, 1L)) && !identical(values, c(0, 1))) {
        stop(label, " must contain exactly 0 and 1", call. = FALSE)
    }
    invisible(x)
}

write_csv_receipt <- function(data, path) {
    dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
    readr::write_csv(data, path, na = "")
    message("Created: ", path)
    invisible(path)
}

write_parquet_receipt <- function(data, path) {
    dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
    arrow::write_parquet(data, path)
    roundtrip <- arrow::read_parquet(path)
    if (nrow(roundtrip) != nrow(data) || !identical(names(roundtrip), names(data))) {
        stop("Parquet round-trip failed for ", path, call. = FALSE)
    }
    message("Created: ", path)
    invisible(path)
}
