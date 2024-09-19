library(tidyverse)

spain = read_csv('Spain 2004-2023.csv')

fix = spain |>
  filter(!is.na(Date)) 

fix |>
  filter(is.na(URL))


parse_dates = fix |>
  janitor::clean_names() |>
    mutate(date = mdy(date)) |>
  rename(text = main_content) |>
  separate_longer_delim(text, delim = '\n')





write_csv(parse_dates, 'spain_statements.csv')

