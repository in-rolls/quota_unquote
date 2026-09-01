library(here)
library(testthat)

source(here("scripts", "00_utils.R"))

test_that("normalize_name is deterministic and preserves missingness", {
    input <- c("  Bāri-Sadri ", "KUCHAMAN   CITY", NA_character_)
    expect_identical(normalize_name(input), c("bari sadri", "kuchaman city", NA_character_))
})

test_that("assert_unique rejects duplicate business keys", {
    duplicate <- data.frame(key = c("a", "a"))
    expect_error(assert_unique(duplicate, "key", "fixture"), "not unique")
    expect_invisible(assert_unique(data.frame(key = c("a", "b")), "key", "fixture"))
})

test_that("the source manifest pins both inputs", {
    sources <- manifest()$upstream
    expect_true(all(c("pai", "quota_raj") %in% names(sources)))
    expect_match(sources$pai$files$gp_metadata.csv, "^[0-9a-f]{64}$")
    expect_match(
        sources$quota_raj$files[["data/raj/shrug_gp_raj_15_20_block.parquet"]],
        "^[0-9a-f]{64}$"
    )
})

