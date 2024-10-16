library(tidyverse)
greek_data = read_csv(here::here("data", "greece_statements.csv"))

head(greek_data)


fix_dates = greek_data |>
mutate(date = dmy(date, locale = 'el_GR.UTF-8'))

head(fix_dates)


write_csv(fix_dates, here::here("data", "greece_statements.csv"))