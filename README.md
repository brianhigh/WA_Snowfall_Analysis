# WA_Snowfall_Analysis

This repository contains a coding example in R. Results are in the "figures" folder.

## Task

Plot Monthly Avg. New Snowfall at WA Cascade Passes (2005-2024) and
color data points according to ENSO designation (El Niño, La Niña, Neutral)

## Science Question

How do El Niño & La Niña climate patterns relate to snowfall in WA Cascades?

## Should we plot new or total snowfall? (answered by Copilot GPT-5)

### Why new snowfall is more useful:

- ENSO primarily affects precipitation and storm tracks, not snowpack retention.
- Total snow depth can be misleading in warmer El Niño winters (where snow melts
faster) or colder La Niña winters (where snow persists longer).
- If your goal is to correlate ENSO with snowfall production, new snowfall is
the cleaner metric because it isolates the precipitation component.

### When Total Snowfall Might Matter:

- If you're studying water resource availability or snowpack for hydrology,
total snow depth could be relevant because it reflects storage.
- But for climate signal detection, new snowfall is generally preferred.
