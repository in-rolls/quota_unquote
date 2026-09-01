# Compare Rajasthan and UP PAI estimates on a common standardized scale.
# Output: figs/pai_effects_comparison.pdf

library(dplyr)
library(ggplot2)
library(here)
library(readr)

source(here("scripts", "00_config.R"))

results <- bind_rows(
    read_csv(here("tabs", "up_pai_effects.csv"), show_col_types = FALSE) |>
        transmute(
            state = "Uttar Pradesh",
            sample = .data$sample,
            estimate = .data$difference_sd,
            conf_low = .data$hc2_conf_low_sd,
            conf_high = .data$hc2_conf_high_sd
        ),
    read_csv(here("tabs", "raj_pai_effects.csv"), show_col_types = FALSE) |>
        transmute(
            state = "Rajasthan",
            sample = .data$sample,
            estimate = .data$effect_sd,
            conf_low = .data$hc2_conf_low_sd,
            conf_high = .data$hc2_conf_high_sd
        )
) |>
    mutate(
        label = paste(.data$state, .data$sample, sep = ": "),
        label = factor(
            .data$label,
            levels = rev(c(
                "Uttar Pradesh: PAI 2.0 primary",
                "Uttar Pradesh: PAI 1.0 replication",
                "Rajasthan: PAI 2.0 primary",
                "Rajasthan: PAI 1.0 replication"
            ))
        ),
        primary = grepl("PAI 2.0", .data$sample, fixed = TRUE)
    )

if (nrow(results) != 4L || any(is.na(results$label))) {
    stop("The cross-state PAI figure requires exactly four known estimates", call. = FALSE)
}

figure <- ggplot(results, aes(x = .data$estimate, y = .data$label)) +
    geom_vline(
        xintercept = 0,
        linetype = "dashed",
        color = COLORS_PUB[["secondary"]]
    ) +
    geom_errorbar(
        aes(xmin = .data$conf_low, xmax = .data$conf_high),
        orientation = "y",
        width = 0.12,
        color = COLORS_PUB[["primary"]]
    ) +
    geom_point(
        aes(color = .data$primary),
        size = 2.5,
        show.legend = FALSE
    ) +
    scale_color_manual(
        values = c(`TRUE` = COLORS_PUB[["accent"]], `FALSE` = COLORS_PUB[["primary"]])
    ) +
    coord_cartesian(xlim = c(-0.08, 0.08)) +
    scale_x_continuous(breaks = seq(-0.08, 0.08, by = 0.04)) +
    labs(
        x = "Conditional difference (control-group SDs)",
        y = NULL
    ) +
    theme_pub()

dir.create(here("figs"), showWarnings = FALSE)
ggsave(
    here("figs", "pai_effects_comparison.pdf"),
    figure,
    width = FIG_WIDTH_FULL,
    height = 3.6,
    device = cairo_pdf
)

message("Cross-state PAI comparison figure completed.")
