library(rvest)
library(tidyverse)

phillipines_raw = read_csv("phillipines_statements.csv")


head(phillipines_raw)


phillipines_raw |>
filter(is.nan(urls))

glimpse(phillipines_raw)



phillipines_add_first_link = phillipines_raw |>
mutate(urls = ifelse(urls == "NaN", paste0("https://pco.gov.ph/presidential-speech/speech-by-president-ferdinand-r-marcos-jr-at-the-national-cooperative-day/"), urls))


write_csv(phillipines_add_first_link, "phillipines_statements.csv")


raw_dat = read_csv('phillipines_statements.csv')

links = read_csv('links_to_scrape_phillipines.csv')

add_dates = raw_dat |>
  left_join(links, join_by(urls == links), multiple = 'first') |>
  mutate(date = mdy(dates),
        ## instead of rescraping we are just going to treat the last part of the urls as the title 
        title = basename(urls), 
        title = str_replace_all(title, '-', " "),
        title = str_to_title(title)) |>
  rename(url = urls)


add_dates |>
  filter(is.na(url))

add_dates |>
  filter(is.na(date))



write_csv(add_dates, 'cleaned_phillipine_statements.csv')

### now we need to get the subject  ## to try to speed this up 

