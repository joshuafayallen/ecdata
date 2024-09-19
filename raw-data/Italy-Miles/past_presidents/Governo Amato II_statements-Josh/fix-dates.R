library(tidyverse)

raw_dat = read_csv('statement_data/amato_statements.csv') |>
select(subject:url)

### lets go and fix that 
## thankfully it looks like you have just 
links = read_csv('links.csv')

fix_data = raw_dat |>
  left_join(links, join_by(url), multiple = 'first') |>
  mutate(date = str_squish(date),
         date = str_extract(date, "\\d{2}/\\d{2}/\\d{4}"),
         date= dmy(date))


write_csv(fix_data, "statement_data/fixed_amato_dates.csv")
