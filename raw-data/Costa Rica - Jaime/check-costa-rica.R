library(tidyverse)


raw_dat = read_csv('exe_com_costarica.csv')


clean_up = raw_dat |>
  select(-`...1`)

raw_dat |>
  filter(is.na(date))


raw_dat |>
  filter(is.na(title))


write_csv(clean_up, 'costa_rica_statements.csv')
