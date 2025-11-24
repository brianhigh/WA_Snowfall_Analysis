# WA_Snowfall_Analysis

This repository contains a coding example in R. Results are in the "figures" folder.

## Task 1

Plot Monthly Avg. New Snowfall at WA Cascade Passes (2005-2024) and
color data points according to ENSO designation (El Niño, La Niña, Neutral)

### Science Question

How do El Niño & La Niña climate patterns relate to snowfall in WA Cascades?

#### Copilot GPT-5 Key Takaway:

- El Niño → less snow, higher freezing levels, rain-on-snow events possible.
- La Niña → more snow, colder storms, better ski seasons.
- Strength matters: Strong La Niña = big snow years; weak La Niña = modest boost.

### Should we plot new or total snowfall? (answered by Copilot GPT-5)

#### Why new snowfall is more useful:

- ENSO primarily affects precipitation and storm tracks, not snowpack retention.
- Total snow depth can be misleading in warmer El Niño winters (where snow melts
faster) or colder La Niña winters (where snow persists longer).
- If your goal is to correlate ENSO with snowfall production, new snowfall is
the cleaner metric because it isolates the precipitation component.

#### When total snowfall might matter:

- If you're studying water resource availability or snowpack for hydrology,
total snow depth could be relevant because it reflects storage.
- But for climate signal detection, new snowfall is generally preferred.

### Results

![Monthly Avg. New Snowfall at WA Cascade Passes Scatter Plot](https://github.com/brianhigh/WA_Snowfall_Analysis/blob/main/figures/monthly_avg_new_snowfall_wa_cascade_passes.png)

![Monthly Avg. New Snowfall at WA Cascade Passes Bar Plot](https://github.com/brianhigh/WA_Snowfall_Analysis/blob/main/figures/monthly_avg_new_snowfall_wa_cascade_passes_bar.png)

## Task 2

Plot Snowfall in Washington Cascades during ENSO Phases (1950–2004) and 
Percentage Difference in Snowfall (Strong vs Weak ENSO Phases).

### Science Question (answered by Copilot GPT-5)

How does the snowfall amount compare between strong and weak ENSO phases in the Washington Cascades?

- La Niña: Strong phases deliver 20–37% more snowfall than weak phases across sites.
- El Niño: Strong phases are generally lower than weak phases (negative percentages), meaning weak El Niño winters tend to have slightly more snow than strong ones.

### Results

![Snowfall in Washington Cascades during ENSO Phases (1950–2004)](https://github.com/brianhigh/WA_Snowfall_Analysis/blob/main/figures/Snowfall_in_Washington_Cascades_during_ENSO_Phases_by_Site.png)

![Percentage Difference in Snowfall (Strong vs Weak ENSO Phases)](https://github.com/brianhigh/WA_Snowfall_Analysis/blob/main/figures/Percentage_Difference_in_Snowfall_by_Site_and_ENSO_Phase.png)
