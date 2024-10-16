library(tidyverse)

raw_dat = read_csv('all_italian_statements.csv')

check = raw_dat |>
  filter(is.na(date)) |>
  distinct(title, .keep_all = TRUE)

fix_data = check |>
  pull('title')

check2 = raw_dat |>
  filter(title == fix_data[4])

check2$text[2]


manual_fixes = raw_dat |>
  mutate(fix_date = case_when(title == fix_data[1] ~ '2023-July-23',
                              title == fix_data[2] ~ '2023-May-25',
                              title == fix_data[3] ~ '2023-May-13',
                              title == fix_data[4] ~ '2022-December-15'),
         url_fix = case_when(title == fix_data[1] ~ 'https://www.governo.it/it/articolo/conferenza-internazionale-su-sviluppo-e-migrazioni-punto-stampa-finale/23263', 
        title == fix_data[2] ~ 'https://www.governo.it/it/articolo/visita-emilia-romagna-punto-stampa-meloni-von-der-leyen/22708',
      title == fix_data[3] ~ 'https://www.governo.it/it/articolo/dichiarazioni-alla-stampa-con-il-presidente-dellucraina-zelensky/22614',
      title == fix_data[4] ~ 'https://www.governo.it/it/articolo/videomessaggio-all-assemblea-nazionale-di-confagricoltura-2022/21298'),
    fix_date = ymd(fix_date),
  date = coalesce(date, fix_date),
 url = coalesce(url, url_fix)) |>
  select(title, text, date, url, executive)


write_csv(manual_fixes, 'all_italian_statements.csv')
