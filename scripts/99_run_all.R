# 99_run_all.R
# Run the Rajasthan, UP, and Mumbai preparation, linkage, and analysis pipeline.
# Output: prepared data, linkage audits, review queues, estimates, and a log.

library(here)

dir.create(here("logs"), showWarnings = FALSE)
log_file <- here("logs", paste0("pipeline_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".log"))

log_msg <- function(message_text, level = "INFO") {
    line <- sprintf(
        "[%s] %s: %s",
        format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
        level,
        message_text
    )
    message(line)
    cat(line, "\n", file = log_file, append = TRUE)
}

run_script <- function(script_name) {
    started <- Sys.time()
    had_warning <- FALSE
    log_msg(paste("START", script_name))
    tryCatch(
        withCallingHandlers(
            source(here("scripts", script_name), local = new.env(parent = globalenv())),
            warning = function(warning_condition) {
                had_warning <<- TRUE
                log_msg(
                    paste("WARNING in", script_name, ":", conditionMessage(warning_condition)),
                    "WARN"
                )
                invokeRestart("muffleWarning")
            }
        ),
        error = function(error_condition) {
            log_msg(
                paste("ERROR in", script_name, ":", conditionMessage(error_condition)),
                "ERROR"
            )
            stop(
                "Pipeline halted at ", script_name, ": ", conditionMessage(error_condition),
                call. = FALSE
            )
        }
    )
    elapsed <- as.numeric(difftime(Sys.time(), started, units = "secs"))
    suffix <- if (had_warning) " [with warnings]" else ""
    log_msg(sprintf("DONE  %s (%.1fs)%s", script_name, elapsed, suffix))
}

run_command <- function(command, args, label) {
    log_msg(paste("START", label))
    status <- system2(command, args, stdout = "", stderr = "")
    if (!identical(status, 0L)) {
        log_msg(paste("ERROR in", label, "with exit status", status), "ERROR")
        stop(label, " failed with exit status ", status, call. = FALSE)
    }
    log_msg(paste("DONE ", label))
}

message("\n### PHASE 1: SOURCE PREPARATION ###")
run_script("01a_pai_prepare.R")
run_script("01b_raj_treatment_prepare.R")
run_script("01c_pai2_group_audit.R")
run_script("01d_up_treatment_prepare.R")
run_script("01e_up_pai_prepare.R")
run_script("01f_bmc_prepare.R")

message("\n### PHASE 2: EXACT LINKAGE AND REVIEW QUEUES ###")
run_script("02a_raj_pai_join.R")
run_command(
    here(".venv", "bin", "python"),
    here("scripts", "02b_raj_pai_fuzzy_candidates.py"),
    "preclink review queue"
)
run_script("02c_up_pai_join.R")

message("\n### PHASE 3: DESIGN GATES ###")
run_script("98_validate_design.R")
run_script("98b_validate_up_design.R")
run_script("98c_validate_bmc_design.R")

message("\n### PHASE 4: ESTIMATION ###")
run_script("03a_raj_pai_effects.R")
run_script("03b_up_pai_effects.R")
run_script("03c_pai_comparison.R")
run_script("03d_bmc_praja_effects.R")

log_msg("Rajasthan, UP, and Mumbai pipeline completed.")
