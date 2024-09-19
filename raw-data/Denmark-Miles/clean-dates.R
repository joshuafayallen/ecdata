library(tidyverse)

press_dat = read_csv('danish_press_releases_danish.csv')


speech_dat = read_csv('danish_speeches.csv')




bound_dat = bind_rows(press_dat, speech_dat) |>
  mutate(date = str_squish(date),
         date_fix = dmy(date))

check =  bound_dat |>
   filter(is.na(date_fix)) |>
   select(date, links) |>
   distinct(links) |>
  pull('links')


fix_dates = bound_dat |>
  mutate(date = case_match(links,
    ## we are doing dmy 
   check[1] ~ '01-01-2024',
   ## this is just announcing the opening of the baltic pipeline
  check[2] ~ '22-09-2022',
  ## cross checked this with the german government since no year listed 
  ## it looks like the topics are mostly the same https://www.bundesregierung.de/breg-en/news/frederiksen-berlin-2004156
  check[3] ~ '09-02-2022',
  ## this is just celebrating the princess's 50th birthday so 1972 + 50
 check[4] ~  '05-02-2022',
 ## https://www.kongehuset.dk/kalender/h-m-dronningen-modtager-statsministeren-i-forbindelse-med-aendringer-i-regeringen 
 check[5] ~ '04-02-2022',
.default = date),
date = dmy(date),
date = coalesce(date, date_fix)) |>
  select(-date_fix) |>
  rename(url = links)

glimpse(fix_dates)

fix_dates |>
  filter(is.na(date))


write_csv(fix_dates, 'danish_statements_danish.csv')
