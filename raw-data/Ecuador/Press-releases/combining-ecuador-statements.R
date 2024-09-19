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
  rename(subject = subject_of_statement) |>
  mutate(type = 'Press Release')


fix2 = readin_data$ecuaor_statements |>
  rename(url = source)

## lets just replace this 

readin_data$all_ecuador_press_statements = fix_data

readin_data$ecuaor_statements = fix2

all_together = readin_data |>
  list_rbind() |>
  mutate(url = coalesce(url, source)) |>
  select(-source)

write_csv(all_together, 'ecuador_statements.csv')
