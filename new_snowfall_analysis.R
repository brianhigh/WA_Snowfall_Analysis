# Plot Monthly Avg. New Snowfall at WA Cascade Passes (2005-2024) and
# color data points according to ENSO designation (El Niño, La Niña, Neutral)
#
# Science Question:
# How do El Niño & La Niña climate patterns relate to snowfall in WA Cascades?
#
# Should we plot new or total snowfall? (answered by Copilot GPT-5)
#
# Why new snowfall is more useful:
# ENSO primarily affects precipitation and storm tracks, not snowpack retention.
# Total snow depth can be misleading in warmer El Niño winters (where snow melts
# faster) or colder La Niña winters (where snow persists longer).
# If your goal is to correlate ENSO with snowfall production, new snowfall is
# the cleaner metric because it isolates the precipitation component.
#
# When Total Snowfall Might Matter:
# If you're studying water resource availability or snowpack for hydrology,
# total snow depth could be relevant because it reflects storage.
# But for climate signal detection, new snowfall is generally preferred.

# Load required packages using pacman
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(httr, xml2, rvest, dplyr, tidyr, ggplot2, lubridate, purrr,
               here, jsonlite, readr, stringr, forcats)

# Define a function to return data and figures directories as a list
create_directories <- function() {
  data_dir <- here("data")
  if (!dir.exists(data_dir)) dir.create(data_dir, recursive = TRUE)

  figures_dir <- here("figures")
  if (!dir.exists(figures_dir)) dir.create(figures_dir, recursive = TRUE)

  list(data_dir = data_dir, figures_dir = figures_dir)
}

# Define define a function to return pass, number, and year as a data.frame
create_pass_dataframe <- function() {
  pass <- c("Blewett", "Stevens", "Snoqualmie", "White")
  pass_num <- c(1, 10, 11, 12)
  pass_year <- 2005:2024
  data.frame(pass = pass, pass_num = pass_num, pass_year = pass_year)
}

# Define a function to download ENSO data
get_enso_data <- function(data_dir) {
  enso_file <- here(data_dir, "enso_data.csv")

  if (file.exists(enso_file)) {
    message("Loading ENSO data from cache..")
    return(read.csv(enso_file))
  }

  message("Downloading ENSO data from ggweather..")
  enso_url <- "https://ggweather.com/enso/oni.htm"
  page <- read_html(enso_url)

  oni_table <- suppressWarnings(
    page %>%
      html_nodes("table") %>% .[[3]] %>%
      html_table(fill = TRUE, header = TRUE) %>%
      mutate(year = str_replace(Season, '(\\d+)-\\d+', '\\1')) %>%
      pivot_longer(cols = c(-`ENSO Type`, -Season, -year),
                   names_to = "Months", values_to = "ONI") %>%
      mutate_all(~na_if(., "")) %>%
      mutate(year = as.numeric(year),
             ONI = as.numeric(ONI)) %>%
      group_by(year) %>%
      summarize(mean_ONI = mean(ONI, na.rm = TRUE)) %>%
      mutate(ENSO = case_when(
        mean_ONI >= 0.5 ~ "El Niño",
        mean_ONI <= -0.5 ~ "La Niña",
        .default ~ "Neutral"
      ))
  )

  write.csv(oni_table, enso_file, row.names = FALSE)
  oni_table
}

# Define a function to download snowfall data
download_snowfall_data <- function(url) {
  page <- read_html(url)
  page_json <- page %>% html_node("p") %>% html_text()
  fromJSON(page_json) %>% select(-dailySnowFall)
}

# Define a function to download snowfall data
get_snowfall <- function(df, data_dir) {
  snowfall_file <- here(data_dir, "snowfall_data.csv")

  if (!file.exists(snowfall_file)) {
    # Define base url for snowfall data download
    base_url <- "https://wsdot.com/Travel/Real-time/Service/api/MountainPass/"

    # Construct URLs for each pass/year
    df_snowfall <- df %>%
      group_by(pass_num, pass_year) %>%
      mutate(
        url = map2_chr(
          .x = pass_num, .y = pass_year,
          ~ paste0(base_url, "SnowFallData?", "MountainPassId=",
                   .x, "&", "Year=", .y)))

    # Download snowfall data
    df_snowfall <- df_snowfall %>%
      group_by(pass_num, pass_year) %>%
      mutate(snowfall = map(url, download_snowfall_data)) %>%
      select(-url) %>%
      unnest(snowfall) %>%
      select(-pass_num, -pass_year, -displayOrder) %>%
      rename(avg_new_snowfall_in = avgNewSnowfallInches,
             avg_tot_snowfall_in = avgTotalSnowfallInches,
             mo_num = monthNum) %>% 
      group_by(pass_num, pass_year, mo_num) %>%
      mutate(date = as.Date(paste(year, mo_num, 1, sep = "-"))) %>%
      select(pass, year, month, date, avg_new_snowfall_in, avg_tot_snowfall_in)

    # Save snowfall data
    write_csv(df_snowfall, snowfall_file)
  } else {
    df_snowfall <- read_csv(snowfall_file, show_col_types = FALSE)
  }
}

# Main execution
dirs <- create_directories()
df_pass <- create_pass_dataframe()
enso_map <- get_enso_data(dirs$data_dir) %>% filter(year %in% df_pass$pass_year)
snow_data <- get_snowfall(df_pass, dirs$data_dir)

# Merge ENSO info
snow_data <- snow_data %>% left_join(enso_map, by = "year")

# Save combined CSV
write_csv(snow_data, here(dirs$data_dir, "cascade_snowfall.csv"))

# Prepare factor variable for x-axis labels
mos <- c(10:12, 1:5)
snow_data <- snow_data %>%
  mutate(mo_num_char =
           factor(str_pad(as.character(mo_num), 2, pad = "0"),
                  levels = str_pad(as.character(mos), 2, pad = "0"),
                  labels = month.abb[mos],
                  ordered = TRUE)) %>%
  drop_na(mo_num_char)

# Plot Monthly Avg. New Snowfall at WA Cascade Passes
plot1 <- ggplot(snow_data,
                aes(x = mo_num_char,
                    y = avg_new_snowfall_in,
                    color = ENSO, group = pass_year)) +
  geom_point(alpha = 0.5) +
  facet_wrap(~ pass, scales = "free_y") +
  scale_color_manual(values =
                       c("El Niño" = "red",
                         "La Niña" = "blue",
                         "Neutral" = "violet")) +
  labs(title = paste0("Monthly Avg. New Snowfall at WA Cascade Passes (",
                      min(df_pass$pass_year), "-", max(df_pass$pass_year), ")"),
       caption = "Data Sources: WSDOT Snowfall report and GGWeather ENSO ONI",
       x = "Month",
       y = "Monthly Avg. New Snowfall (inches)", color = "ENSO Phase") +
  theme_minimal()

ggsave(plot1,
       filename = here(dirs$figures_dir,
                       "monthly_avg_new_snowfall_wa_cascade_passes.png"))

# Prepare data for bar plot
summarized_snow_data <- snow_data %>%
  group_by(pass, ENSO) %>%
  summarise(avg_new_snowfall_in = mean(avg_new_snowfall_in), .groups = "drop")

# Plot summarized data as bar plot
plot2 <- ggplot(summarized_snow_data,
                aes(x = avg_new_snowfall_in, y = pass, group = ENSO)) +
  geom_col(aes(fill = ENSO), position = position_dodge(reverse = TRUE)) +
  scale_fill_manual(values =
                      c("El Niño" = "red",
                        "La Niña" = "blue",
                        "Neutral" = "violet")) +
  theme_minimal() +
  labs(title =
         paste0("Monthly Avg. New Snowfall at WA Cascade Passes (",
                min(df_pass$pass_year), "-", max(df_pass$pass_year), ")"),
       caption = "Data Sources: WSDOT Snowfall report and GGWeather ENSO ONI",
       y = "Pass", x = "Monthly Avg. New Snowfall (inches)")

ggsave(plot2,
       filename = here(dirs$figures_dir,
                       "monthly_avg_new_snowfall_wa_cascade_passes_bar.png"))
