library(ecdata)
library(tidyverse)

full_data = load_ecd(full_ecd = TRUE)

glimpse(full_data)


fix_year = full_data |>
  mutate(date = ifelse(year_of_statement == 1912, ymd('2011-01-12'), date),
         date =  as_datetime(date),
         year_of_statement = year(date))


brazil = fix_year |>
  filter(country == 'Brazil')

write_parquet(fix_year, 'piggyback-release-data/full_ecd.parquet')

write_parquet(brazil, 'piggyback-release-data/brazil.parquet')

walk(c('piggyback-release-data/full_ecd.parquet',
   'piggyback-release-data/brazil.parquet'), \(x) pb_upload(x, repo ='Executive-Communications-Dataset/ecdata', tag = '1.0.0'))
