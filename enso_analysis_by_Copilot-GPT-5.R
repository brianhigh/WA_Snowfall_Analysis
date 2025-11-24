# R Script: ENSO Snowfall Analysis for Washington Cascades
# Includes web scraping, data processing, and visualization

# ------------------------------------------------------------------------------
# This script was created by Copilot GPT-5 with these prompts:
#
# - How do El Niño & La Niña climate patterns relate to snowfall in WA Cascades?
# - Show a chart comparing snowfall during El Niño and La Niña years.
# - Compare snowfall in strong vs weak La Niña
# - Add El Niño data for full ENSO comparison.
#   Show percentage snowfall difference.
# - Write an R script which reproduces this analysis, including generation of 
# all plots, as well as the web scraping steps needed to download and import 
# the necessary data.
#
# Several manual edits were made to this code, as noted in the comments below.
# ------------------------------------------------------------------------------

# Load required libraries
library(rvest)
library(dplyr)
library(ggplot2)
library(tidyr)
library(readr)
library(here)         # Added this manually for reproducible file paths
library(RColorBrewer) # Added this manually to support a custom palette
library(forcats)      # Added this manually to support reodering factors
library(stringr)      # Added this manually to support data cleanup

# -----------------------------------------------------------------------------
# NOTE: Step 1. required significant manual editing to make it work properly.
#
# Step 1: Web scrape SkiMountaineer ENSO snowfall table

# Create data directory if missing
data_dir <- here("data")
if (!dir.exists(data_dir)) dir.create(data_dir, recursive = TRUE)

# Create figures directory if missing
figures_dir <- here("figures")
if (!dir.exists(figures_dir)) dir.create(figures_dir, recursive = TRUE)

input_file <- here(data_dir, "CascadeSnowENSO.csv")
if(!file.exists(input_file)) {
  url <- 'https://www.skimountaineer.com/CascadeSki/CascadeSnowENSO.html'
  page <- read_html(url)
  
  # Extract annual snowfall table
  table_node <- html_nodes(page, 'table')[[7]]
  data <- html_table(table_node, fill = TRUE) %>% tail(-2) %>% .[, c(2:3, 5:18)]
  
  # Clean data
  names(data) <- str_remove(data[1, ], ' ')
  data <- data[-1, ] %>% drop_na(TotalYears) %>% 
    filter(ENSOPhase != 'Overall Average') %>%
    filter(str_detect(TotalYears, 'Max|Min', negate = TRUE)) %>%
    mutate(across(everything(), str_remove, '"')) %>%
    mutate(across(-ENSOPhase, as.numeric)) %>%
    select(
      matches('ENSO|Holden|Stevens|Snoq|Stampede|Paradise|Longmire')) %>%
    pivot_longer(-ENSOPhase, names_to = 'Site', values_to = 'Depth') %>%
    mutate(Site = str_replace_all(Site, '([a-z\\.])([^a-z\\.\\d])', '\\1 \\2')) %>% 
    mutate(Site = str_replace_all(Site, '(\\d+)([a-z]+)', ' (\\1 \\2)')) %>% 
    pivot_wider(id_cols = Site, names_from = 'ENSOPhase', values_from = 'Depth')
  
  # Rename columns
  colnames(data) <- c('Site', 'Strong_El_Nino', 'Weak_El_Nino', 
                      'Neutral', 'Weak_La_Nina', 'Strong_La_Nina')
  
  # Save data as CSV file
  write_csv(data, input_file)
} else {
  data <- read_csv(input_file, show_col_types = FALSE)
}

#
# End of the majority of manual edits. The rest are commented below.
# -----------------------------------------------------------------------------

# Step 2: Calculate averages and percentage differences
data <- data %>% mutate(
  PctDiff_LaNina = ((Strong_La_Nina - Weak_La_Nina) / Weak_La_Nina) * 100,
  PctDiff_ElNino = ((Strong_El_Nino - Weak_El_Nino) / Weak_El_Nino) * 100
)

# Step 3: Plot grouped bar chart for snowfall
data_long <- data %>% select(!starts_with('PctDiff')) %>%
  pivot_longer(cols = -Site, names_to = 'Phase', values_to = 'Snowfall') 

# Define a custom color palette - Manually added
phase_pal <- brewer.pal(n = 12, name = "Paired")[c(6:5, 9, 1:2)]

# Sort Phase labels - Manually added
phase_labels <- c('Strong El Niño', 'Weak El Niño', 'Neutral', 
                  'Weak La Niña', 'Strong La Niña')
data_long$Phase <- factor(data_long$Phase, labels = phase_labels, ordered = TRUE)

# Manually reversed Site order with fct_rev()
ggplot(data_long, aes(x = fct_rev(Site), y = Snowfall, fill = Phase)) +
  geom_bar(stat = 'identity', position = 'dodge') +
  scale_fill_discrete(palette = phase_pal) +
  labs(title = 'Snowfall in Washington Cascades during ENSO Phases (1950–2004)',
       x = 'Cascade Sites', y = 'Snowfall (inches)', fill = "ENSO Phase",
       caption = "Source: www.skimountaineer.com") +  # Manual: fill & caption
  theme_minimal() + 
  guides(fill = guide_legend(reverse=TRUE)) +  # Manually added to match plot
  coord_flip()     # Manually added coord_flip() to pivot axes

# Manually added to save plot as PNG
ggsave(here(figures_dir, 
            "Snowfall_in_Washington_Cascades_during_ENSO_Phases_by_Site.png")
)
       
# Step 4: Plot percentage differences
pct_long <- data %>% select(Site, PctDiff_LaNina, PctDiff_ElNino) %>%
  pivot_longer(cols = -Site, names_to = 'Category', values_to = 'PctDiff')

# Define a custom color palette - Manually added
category_pal <- brewer.pal(n = 12, name = "Paired")[c(6, 2)]

# Sort Category labels - Manually added
category_labels <- c('El Niño', 'La Niña')
pct_long$Category <- factor(pct_long$Category, labels = category_labels, 
                            ordered = TRUE)

# Manually reversed Site order with fct_rev()
ggplot(pct_long, aes(x = fct_rev(Site), y = PctDiff, fill = Category)) +
  geom_bar(stat = 'identity', position = 'dodge') +
  scale_fill_discrete(palette = category_pal) +
  labs(title = 'Percentage Difference in Snowfall (Strong vs Weak ENSO Phases)',
       x = 'Cascade Sites', y = 'Difference (%)', fill = "ENSO Category",
       caption = "Source: www.skimountaineer.com") +  # Manual: fill & caption
  theme_minimal() + 
  guides(fill = guide_legend(reverse=TRUE)) +  # Manually added to match plot
  coord_flip()     # Manually added coord_flip() to pivot axes

# Manually added to save plot as PNG
ggsave(here(figures_dir, 
            "Percentage_Difference_in_Snowfall_by_Site_and_ENSO_Phase.png"))
