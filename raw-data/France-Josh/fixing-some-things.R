library(tidyverse)

## umm it looks like you may have created some more problems for yourself 
## so lets recreate what you did here and then figure out what to do 

raw_links_data = read_csv('president/raw_links_data.csv')

text_data = read_csv("president/text_data_french_pres.csv")

pdf_data = read_csv('president/pdf_text_dat.csv')


combined_data_from_all = text_data |>
  left_join(raw_links_data, join_by(link))

## ahh it looks like we have only three of the four columns umm the issue is that dnow 

get_subjects = combined_data_from_all |> 
  mutate(subject = sub('.*/[0-9]{4}/[0-9]{2}/[0-9]{2}/', '', link),
         subject = str_replace_all(subject, '-', ' '),
         subject = str_to_title(subject), 
        date_fix = dmy(date, locale = 'fr_FR'), 
      date_fix_two = mdy(date),
      date = coalesce(date_fix, date_fix_two) )  |>
  select(date, subject, text = value, link)

write_csv(get_subjects, 'french_statements.csv')
