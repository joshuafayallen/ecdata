library(tidyverse)


## just going to add the 
raw_dat = read_csv('data/raw_statement_data.csv')

big_data = bind_rows(hong_kong_speeches, speeches_hong_kong)

fix_dates = raw_dat |>
  mutate(fix_date = as.character(strptime(gsub('\\D', '-', date), '%g')),
         fix_date = ifelse(is.na(fix_date), '2022-12-12', fix_date))





make_paragraphs = fix_dates |>
  separate_longer_delim(text, delim = '\n\n') |>
  filter(str_detect(text, '\n\t\t\t\t', negate = TRUE)) |>
  separate_longer_delim(text, delim = '\n') |>
  select(-date) |>
  rename(date = fix_date)

write_csv(make_paragraphs, 'data/hong_kong_statements.csv')

