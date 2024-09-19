library(tidyverse)
library(rvest)

brazil_files = list.files(path = here::here("Brazil-juan"),
                          pattern = "*.csv",
                          full.names = TRUE)

names_vec = basename(brazil_files) |>
  str_remove('.csv') |>
  str_to_lower()


read_in = map(brazil_files, read_csv)  

names(read_in) = names_vec




list2env(read_in, envir = .GlobalEnv)

rm(brazil_statements)


roussef_links_rescrape = rousseff |>
  filter(is.na(Date)) |>
  distinct(URL, .keep_all = TRUE) |>
  mutate(date = case_match( URL,
            URL[1] ~ '17-03-2016',
            URL[2] ~ '03-02-2016',
            URL[3] ~ '17-09-2013',
            URL[4] ~ '16-04-2015',
            URL[5] ~ '16-04-2015', 
            URL[6] ~ '21-10-2013',
            URL[7] ~ '21-10-2013',
            URL[8] ~ '06-09-2013',
            URL[9] ~ '06-09-2013',
            URL[10] ~ '24-06-2013',
            URL[11] ~ '24-06-2013',
            URL[12] ~ '21-06-2013',
            URL[13] ~ '21-06-2013',
            URL[14] ~ '18-06-2013',
            URL[15] ~ '18-06-2013',
            URL[16] ~ '01-05-2013',
            URL[17] ~ '23-01-2013',
            URL[18] ~ '13-05-2012',
            URL[19] ~ '21-03-2011',
            URL[20] ~ '10-02-2012',
            URL[21] ~ '01-01-2011',
            URL[22] ~ '01-01-2011' )) |>
  select(URL, date2 = date)

fixed_roussef = rousseff |>
  left_join(roussef_links_rescrape, join_by(URL)) |>
  mutate(date = coalesce(Date, date2),
        date = dmy(date)) 


links_vec = fixed_roussef |>
  filter(is.na(date)) |>
  distinct() |>
  pull('URL')

fix_remains = fixed_roussef |>
  mutate(date_fix = case_match(URL,
    links_vec[1] ~ '01-03-2013',
    links_vec[2] ~ '01-03-2013',
    links_vec[3] ~ '01-03-2013',
    links_vec[4]~ '01-03-2012',
    links_vec[5] ~ '01-03-2011',
    links_vec[6] ~  '01-03-2011'
  ),
date_fix = dmy(date_fix)) |>
  select(URL, date_fix)

parsed_roussef_dates = fixed_roussef |>
  left_join(fix_remains, join_by(URL)) |>
mutate(date = coalesce(date, date_fix)) |>
  select(-c(date_fix, date2)) |>
  janitor::clean_names() |>
  select(url:type)

glimpse(parsed_roussef_dates)


parsed_roussef_dates |>
  filter(is.na(date))


lula_1 = lula_1 |>
 mutate(date = dmy(File)) 


extract_dates = lula_1 |>
  filter(is.na(date)) |>
  mutate(extract_date = str_extract_all(File, '\\d+-\\d+-\\d{4}')) |>
  unnest(extract_date) |>
  mutate(date_two = dmy(extract_date)) |>
  select(File, date_two)

fixed_lulas = lula_1 |>
  left_join(extract_dates, join_by(File) ) |>
  mutate(date = coalesce(date_two, date),
         title = gsub('[[:digit:]]+', '', File),
        title = str_remove_all(title, '-|--|---')) |>
  select(-date_two) |>
  janitor::clean_names() |>
  select(date, text = content, title, url = file, type)


parse_bolsonaro = bolsonaro |>
  mutate(Date = dmy(Date)) |>
  janitor::clean_names() 

parse_cardoso = cardoso |>
  mutate(Date = dmy(Date)) |>
  janitor::clean_names()


