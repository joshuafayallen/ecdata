library(tidyverse)

files_list = list.files(pattern = '.csv$', full.names = TRUE, recursive = TRUE)

files_data = files_list |>
  as_tibble() |>
  filter(str_detect(value, 'links', negate = TRUE)) |>
  mutate(file_name = basename(value),
        file_name = str_remove(file_name, '.csv')) |>
  filter(file_name %in% c('ecuaor_statements', 'cleaned_ecuador_speeches_combined', 'all_ecuador_press_statements'))




readin_data = map(files_data$value, read_csv)

names(readin_data) = files_data$file_name

fix_data = readin_data$all_ecuador_press_statements |>
  mutate(type = 'Press Release')


fix2 = readin_data$ecuaor_statements |>
  rename(url = source)

## lets just replace this 

readin_data$all_ecuador_press_statements = fix_data

readin_data$ecuaor_statements = fix2

all_together = readin_data |>
  list_rbind() |>
  mutate(title = coalesce(title, subject)) |>
  select(-subject)

all_together |>
  filter(is.na(date))


write_csv(all_together, 'ecuador_statements.csv')

## let

jamie_data = read_csv('exe_com_uruguay.csv')

## looks like the only 
## the problem is the weird ... 

clean_jamie = jamie_data |>
  select(-...1)

raw_dat = read_csv('ecuador_statements.csv')

all_together = bind_rows(clean_jamie, raw_dat)

write_csv(all_together, 'combined_ecuador_statements.csv')


