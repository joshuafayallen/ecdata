library(tidyverse)

current_statements = read_csv('current_hungary_statements.csv')

past_hungary_statements = read_csv('hungarian_statements.csv')

other_past = read_csv('2015-2019-statements.csv')

bound = bind_rows(current_statements, past_hungary_statements, other_past) |>
  mutate(url = coalesce(urls, url),
         title = coalesce(title, subject)) |>
  select(-urls, -subject)


bound |>
  filter(is.na(url))

write_csv(bound, 'combined_hungary_statements.csv')
