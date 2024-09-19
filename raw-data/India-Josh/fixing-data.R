library(arrow)
library(tidyverse)


raw_dat = read_parquet('indian_statements.parquet')


parse_dates = raw_dat |>
  mutate(date = dmy(date),
         language = sub(".*in/(.*)/news_update.*", "\\1", url),
        language = ifelse(language == 'en', 'English', "Hindi")) 


table(parse_dates$language)


write_csv(parse_dates, 'india_statements.csv')
