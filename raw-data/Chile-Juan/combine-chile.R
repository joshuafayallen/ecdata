library(tidyverse)

files = c('Chile-BORIC2022-2023.csv', 'Chile-PiÑERA2018-2022.csv')

names(files) = c('boric', 'pinera')

readin = lapply(files, read_csv)


list2env(readin, .GlobalEnv)

boric_clean = boric |>
  select(url =summary_url, text:date) |>
  mutate(president = 'Gabriel Boric')

pinera_clean = pinera |> 
  select(url = summary_url, text:date) |>
  mutate(president = 'Sebastián Piñera') 


all_together = bind_rows(boric_clean, pinera_clean)


write_csv(all_together, 'chile_statements.csv')
