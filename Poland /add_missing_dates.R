library(rvest)
library(tidyverse)

raw_dat = read_csv('poland_pm_statements.csv')

missing_dates = raw_dat |>
  filter(is.na(date)) |>
  distinct(url, .keep_all = TRUE)

links_rescrape = pull(missing_dates, url)


raw_dat




fix_missing_dates = raw_dat |>
  mutate(fix_date = case_when(url == links_rescrape[1] ~ '26-09-2020',
                                 url == links_rescrape[2] ~ '10-06-2020',
                                 url == links_rescrape[3] ~ '11-03-2020',
                                 url == links_rescrape[4] ~ '30-01-2020',
                                 url == links_rescrape[5] ~ '16-10-2024' ),
          across(c(fix_date, date), \(x) dmy(x)),
        date = coalesce(date, fix_date)) |>
  select(title, date, text = main_text, url, type)


write_csv(fix_missing_dates, 'poland_pm_statements_fix_missing.csv')


