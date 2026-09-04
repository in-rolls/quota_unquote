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

test_that("the source manifest pins every input", {
    sources <- manifest()$upstream
    expect_true(all(c("pai", "quota_raj", "local_reservations") %in% names(sources)))
    expect_match(
        sources$local_reservations$files[["data/maharashtra/ulb_ward_2012.csv"]],
        "^[0-9a-f]{64}$"
    )
    expect_match(sources$pai$files$gp_metadata.csv, "^[0-9a-f]{64}$")
    expect_match(
        sources$quota_raj$files[["data/raj/shrug_gp_raj_15_20_block.parquet"]],
        "^[0-9a-f]{64}$"
    )
})

test_that("write_tex_macros writes named commands and rejects invalid names", {
    output <- tempfile(fileext = ".tex")
    expect_invisible(write_tex_macros(c(TestValue = "1.23"), output))
    expect_identical(readLines(output), "\\newcommand{\\TestValue}{1.23}")
    expect_error(write_tex_macros(c("Bad1" = "1.23"), output), "letters only")
})

test_that("the fixed-count simulator compiles and is reproducible", {
    simulator <- new.env(parent = globalenv())
    compile_stratified_simulator(simulator)
    first <- simulator$simulate_stratified_statistics(
        c(-1, 1, -2, 2),
        c(0L, 0L, 1L, 1L),
        c(1L, 1L),
        20L,
        42L
    )
    second <- simulator$simulate_stratified_statistics(
        c(-1, 1, -2, 2),
        c(0L, 0L, 1L, 1L),
        c(1L, 1L),
        20L,
        42L
    )
    expect_identical(first, second)
    expect_true(all(first %in% c(-3, -1, 1, 3)))
})
