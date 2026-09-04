# 00_config.R
# Shared constants, labels, and figure settings.
# Output: none

STATE_PRIMARY <- "Rajasthan"
STATE_UP <- "Uttar Pradesh"
ELECTION_YEAR_PRIMARY <- 2020L
ELECTION_YEAR_UP <- 2021L
PAI_YEAR_PRIMARY <- "2023-2024"
PAI_YEAR_REPLICATION <- "2022-2023"
PAI_T8_SLUG <- "t8_panchayat_with_good_governance"

# Mumbai (BMC): three councils, one Praja survey wave per council in the primary
# sample, the last non-election year of each term.
BMC_COUNCILS <- c(2007L, 2012L, 2017L)
BMC_PRIMARY_WAVES <- c("2011", "2016", "2018")
BMC_WOMEN_SEATS <- c("2007" = 76L, "2012" = 114L, "2017" = 114L)
BMC_SERVICE_ITEMS <- c(
    "roads", "traffic", "gardens", "transport", "hospitals", "schools", "power",
    "water", "flooding", "pollution", "crime", "law_order", "sanitation"
)
BMC_INDEX14_ITEMS <- c(BMC_SERVICE_ITEMS, "corruption")
BMC_INDEX18_ITEMS <- c(
    BMC_INDEX14_ITEMS, "recall_party", "recall_name", "accessibility", "quality_of_life"
)

DICT_TREAT <- c(
    "an_women_reserved" = "Women-reserved seat"
)

theme_pub <- function(base_size = 11, base_family = "") {
    ggplot2::theme_bw(base_size = base_size, base_family = base_family) +
        ggplot2::theme(
            panel.grid.major = ggplot2::element_blank(),
            panel.grid.minor = ggplot2::element_blank(),
            panel.border = ggplot2::element_rect(
                color = "gray30", fill = NA, linewidth = 0.5
            ),
            axis.ticks = ggplot2::element_line(color = "gray30", linewidth = 0.3),
            axis.text = ggplot2::element_text(color = "gray20"),
            axis.title = ggplot2::element_text(color = "gray10", face = "plain"),
            legend.background = ggplot2::element_blank(),
            legend.key = ggplot2::element_blank(),
            legend.title = ggplot2::element_text(face = "plain", size = ggplot2::rel(0.9)),
            strip.background = ggplot2::element_blank(),
            strip.text = ggplot2::element_text(face = "bold", hjust = 0),
            plot.margin = ggplot2::margin(10, 10, 10, 10),
            plot.title = ggplot2::element_text(face = "bold", hjust = 0),
            plot.subtitle = ggplot2::element_text(color = "gray40", hjust = 0)
        )
}

COLORS_PUB <- c(
    primary = "#2C3E50",
    secondary = "#7F8C8D",
    accent = "#C0392B",
    highlight = "#27AE60",
    light = "#BDC3C7"
)

FIG_WIDTH_FULL <- 6.5
FIG_WIDTH_HALF <- 3.25
FIG_HEIGHT <- 4.5
