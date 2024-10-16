library(tidyverse)


raw_dat = read_csv('text_data/ecuador_speeches_combined.csv')

glimpse(raw_dat)

pdf_data = raw_dat |>
  ## the first row of all the pdfs are just the title of the pdf 
  mutate(subject_flag = as.integer(row_number() < 2), .by = file_name) |>
  mutate(subject_fix = ifelse(subject_flag == 1, raw_text, NA)) |>
  group_by(file_name) |>
  fill(subject_fix, .direction = 'down') |>
  ungroup()

pdf_data |>
  filter(is.na(url))


clean_up = pdf_data |>
  mutate(subject = coalesce(subject, subject_fix),
         text = coalesce(text, raw_text)) |>
  select(date, subject, text, url, type = type_of_communication)


write_csv(clean_up, 'cleaned_ecuador_speeches_combined.csv')



raw_dat = read_csv('cleaned_ecuador_speeches_combined.csv') |>
  rename(title = subject)


write_csv(raw_dat, 'cleaned_ecuador_speeches_combined.csv')
