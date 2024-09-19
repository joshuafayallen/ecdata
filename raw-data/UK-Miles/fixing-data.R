library(rvest)
library(tidyverse)

files = list.files(pattern = '*.csv')

tib = tibble(files = files) |>
  filter(str_detect(files, 'links', negate = TRUE))


readin = map(tib$files, read_csv)


names_vec =  tib |>
  mutate(names = str_remove(files, '.csv')) |>
  pull('names')


names(readin) = names_vec



list2env(readin, envir = .GlobalEnv)




tib = tibble(files = files) |>
  filter(str_detect(files, 'links'))


readin = map(tib$files, read_csv)


names_vec =  tib |>
  mutate(names = str_remove(files, '.csv')) |>
  pull('names')


names(readin) = names_vec



list2env(readin, envir = .GlobalEnv)

test_johnson = johnson_links$links[2]

## umm interestingly the johnson links aren't working so 

fix_johnson_links = johnson_links |>
  mutate(links = paste0('https://www.gov.uk', value))

test_johnson = fix_johnson_links$links[1]



test_sunak = rishi_links$links[1]

test_may = may_links$links[1]

fix_may = may_links |>
  mutate(links = paste0('https://www.gov.uk', value))

test_truss = truss_links$links[1]

test_cameron = cameron_links$links[1]

fix_cameron = cameron_links |>
  mutate(links = paste0('https://www.gov.uk', value))

test_cameron = fix_cameron$links[1]


big_links = bind_rows(rishi_links, truss_links, fix_johnson_links, fix_cameron, .id = 'minister') |>
  mutate(minister = case_when(minister == 1 ~ 'Rishi Sunak',
                              minister == 2 ~ 'Liz Truss',
                             minister == 3 ~ 'Boris Johnson',
                            minister == 4 ~ 'David Cameron'))

combined_links = write_csv(big_links, 'combined_links.csv')

## okay it looks like for the most part we have all the data we need 
#content > div:nth-child(2) > div:nth-child(1) > div > h1
#content > div:nth-child(2) > div:nth-child(1) > div > h1


sunak = read_html(test_sunak) |>
  html_element('#content > div:nth-child(2) > div:nth-child(1) > div > h1') |>
  html_text()


cameron = read_html(test_cameron) |>
  html_element('#content > div:nth-child(2) > div:nth-child(1) > div > h1') |>
  html_text()

boris = read_html(test_johnson) |>
  html_element('#content > div:nth-child(2) > div:nth-child(1) > div > h1') |>
  html_text()


## so this generally works 

scrapper = \(links){
  
  subject = links |>
    read_html() |>
    html_element('#content > div:nth-child(2) > div:nth-child(1) > div > h1') |>
    html_text() |>
    as_tibble() |>
    mutate(url = links) |>
    rename(subject = value)

   cat('Done Scraping:', links, '\n')
  
  Sys.sleep(5)

  return(subject)


}

test_data = big_links |>
  slice_sample(n =5, by = minister)


 

pos_scrapper = possibly(scrapper)




rishi_titles = map(rishi_links$links, \(x) pos_scrapper(x))

which(lengths(rishi_titles) == 0)

sunak_bound = rishi_titles |>
  list_rbind() |>
  mutate(subject = str_squish(subject))



add_url_sunak = rishi_statements |>
  mutate(title = str_squish(title)) |>
  left_join(sunak_bound, join_by(title == subject), multiple = 'first')



truss_titles = map(truss_links$links, \(x) pos_scrapper(x))

which(lengths(truss_titles) == 0)

truss_bound = truss_titles |>
  list_rbind() |>
  mutate(subject = str_squish(subject))

add_url_truss = truss_statements |>
  mutate(title = str_squish(title)) |>
  left_join(truss_bound, join_by(title == subject))



boris_titles = map(fix_johnson_links$links, \(x) pos_scrapper(x))

which(lengths(boris_titles) == 0)

bound_boris = boris_titles |>
  list_rbind() |>
  mutate(subject = str_squish(subject)) |>
  filter(!is.na(subject))

add_url_boris = johnson_statements |>
  mutate(title = str_squish(title)) |>
  left_join(bound_boris, join_by(title == subject))



cameron_titles = map(fix_cameron$links, \(x) pos_scrapper(x))



which_rescrapes = which(lengths(cameron_titles) == 0)

check = cameron_bound |>
  filter(is.na(subject))



rescrape_links_cameron = fix_cameron |>
  mutate(id = row_number()) |>
  filter(id %in% which_rescrapes)


rescrapes_for_cameron = map(rescrape_links_cameron$links, \(x) scrapper(x))


bound_cameron = cameron_titles |>
  list_rbind()  |>
  rename(title = subject) |>
  mutate(title = str_squish(title))



add_url_cameron = cameron_statements |>
  left_join(bound_cameron)

bound_truss_sunak = bind_rows(add_url_sunak, add_url_truss)



clean_titles_cameron_statements = cameron_statements |>
  mutate(title = str_squish(title))




read_html(fix_cameron$links[1]) |>
  html_element('#content > div:nth-child(3) > div > div.govuk-grid-column-two-thirds.metadata-column > div > dl > dd:nth-child(4)') |>
  html_text()


scrapper = \(links){
  
  subject = links |>
    read_html() |>
    html_element('#content > div:nth-child(2) > div:nth-child(1) > div > h1') |>
    html_text() |>
    as_tibble() |>
    rename(subject = value)

  text = read_html(links) |>
    html_elements('.govspeak p') |>
    html_text() |>
    as_tibble() |>
    rename(text = value)

  date = read_html(links) |>
    html_elements('#content > div:nth-child(3) > div > div.govuk-grid-column-two-thirds.metadata-column > div > dl > dd:nth-child(4)') |>
    html_text() |>
    as_tibble() |>
    rename(date = value)
  
    bound_data = bind_cols(subject, date, text, url = links)
 
   cat('Done Scraping:', links, '\n')
  
  Sys.sleep(5)

  return(bound_data)


}


big = bind_rows(fix_johnson_links, fix_cameron, .id = 'minister')


pos_scrapper = possibly(scrapper)

cameron_rescrape = map(fix_cameron$links, \(x) pos_scrapper(x))

links_vec_rescrape = which(lengths(cameron_rescrape) == 0)


ids_add = fix_cameron |>
  mutate(id = row_number()) |>
  filter(id %in% links_vec_rescrape) |>
  pull('links')

rescraped_cameron_again = map(ids_add, \(x) pos_scrapper(x))

bound_rescrape = list_rbind(rescraped_cameron_again)

check_again = which(lengths(rescraped_cameron_again) == 0)



special_data = \(links = ids_add[6]){
  
  subject = links |>
    read_html() |>
    html_element('#content > div:nth-child(2) > div:nth-child(1) > div > h1') |>
    html_text() |>
    as_tibble() |>
    rename(subject = value)

  text = read_html(links) |>
    html_elements('.govspeak p') |>
    html_text() |>
    as_tibble() |>
    rename(text = value)

  date = read_html(links) |>
    html_elements('#content > header > p') |>
    html_text() |>
    as_tibble() |>
    rename(date = value)
  
    bound_data = bind_cols(subject, date, text, url = links)
 
   cat('Done Scraping:', links, '\n')
  
  Sys.sleep(5)

  return(bound_data)


}

special_dat = special_data()

bound_cameron_rescrape = cameron_rescrape |>
  list_rbind() |>
  bind_rows(bound_rescrape, special_dat) |>
  mutate(date = dmy(date))


write_csv(bound_cameron_rescrape, 'cameron_rescrape_data.csv')


add_cameron_to_sunak_truss = bound_truss_sunak |>
  ## it looks like the issue is that there are some dates that are updated
  ## so we are just going to take the first instance 
  mutate(extract_dates = str_extract(date, '\\b\\d{1,2} [A-Za-z]+ \\d{4}\\b'),
        date = dmy(extract_dates)) |>
  select(-extract_dates) |>
  bind_rows(bound_cameron_rescrape)



write_csv(add_cameron_to_sunak_truss, 'cameron_sunak_truss_statements.csv')

boris_rescrapes = map(fix_johnson_links$links, \(x) pos_scrapper(x)) 

bound_boris = boris_rescrapes |>
  list_rbind()

write_csv(bound_boris, 'boris_johnson_statements_rescrape.csv') 



check_boris = which(lengths(boris_rescrapes) == 0)

rescrape_these = fix_johnson_links |>
  mutate(id = row_number()) |>
  filter(id %in% check_boris) |>
  pull('links')


rescrape_boris_again = map(rescrape_these, \(x) pos_scrapper(x))


rescrape_these |>
  tibble() |>
  write_csv('boris_rescrape_links.csv')


links_rescrape = read_csv('boris_rescrape_links.csv')


rescraped_data = map(links_rescrape$rescrape_these, \(x) pos_scrapper(x))

bound_rescrape = rescraped_data |>
  list_rbind()


links_rescrape$rescrape_these[1]

special_data = \(links ="https://www.gov.uk/government/publications/pms-letter-to-veterans-of-the-uks-nuclear-testing-programme-5-september-2022/prime-ministers-letter-to-veterans-of-the-uks-nuclear-testing-programme" ){
  
  subject = links |>
    read_html() |>
    html_element('#content > div:nth-child(2) > div:nth-child(1) > div > h1') |>
    html_text() |>
    as_tibble() |>
    rename(subject = value)

  text = read_html(links) |>
    html_elements('.govspeak p') |>
    html_text() |>
    as_tibble() |>
    rename(text = value)

  date = read_html(links) |>
    html_elements('#content > header > p') |>
    html_text() |>
    as_tibble() |>
    rename(date = value)
  
    bound_data = bind_cols(subject, date, text, url = links)
 
   cat('Done Scraping:', links, '\n')
  
  Sys.sleep(5)

  return(bound_data)


}

spec_dat = special_data()

bind_rescrape = bind_rows(bound_rescrape, spec_dat)  |>
  mutate(extract_dates = str_extract(date, '\\b\\d{1,2} [A-Za-z]+ \\d{4}\\b'),
date = dmy(extract_dates))

johson_raw = read_csv('boris_johnson_statements_rescrape.csv') |>
  mutate(extract_dates = str_extract(date, '\\b\\d{1,2} [A-Za-z]+ \\d{4}\\b'),
date = dmy(extract_dates)) 


bound = bind_rows(johson_raw, bind_rescrape)

other_pms = read_csv('cameron_sunak_truss_statements.csv')

all_together = bind_rows(bound, other_pms)


write_csv(all_together, 'uk_statements.csv')

raw_dat = read_csv('uk_statements.csv')

fix_urls = raw_dat |>
  filter(is.na(url)) |>
  distinct(title, .keep_all = TRUE) |>
  pull('title')

check = raw_dat |>
  filter(is.na(url))

check |>
  filter(title == fix_urls[2])  |>
  pull('text')


add_links_manual = raw_dat |>
  mutate(url_fix = case_when(title == fix_urls[1] ~ 'https://www.gov.uk/government/news/pm-meeting-with-the-prime-minister-of-belgium-23-january-2024',
                           title == fix_urls[2] ~ 'https://www.gov.uk/government/news/pm-meeting-with-israels-president-isaac-herzog-01-december-2023',
                          title == fix_urls[3] ~ 'https://www.gov.uk/government/news/pm-meeting-with-egyptian-president-abdel-fattah-el-sisi-01-december-2023'),
          url = coalesce(url, url_fix)) |>
  select(subject:url) |>
  rename(title = subject)

write_csv(add_links_manual, 'uk_statements.csv')

## apparently we have missing titles so we are just going to treat the last part of the url as the title since that is kind of how it works 
raw_dat = read_csv('uk_statements.csv')

missing_titles = raw_dat |>
  mutate(fix_titles = ifelse(is.na(title), basename(url), NA),
         fix_titles  = str_replace_all(fix_titles, "-", " "),
         fix_titles = str_to_title(fix_titles),
         title = coalesce(title, fix_titles)) |>
  select(-fix_titles)



missing_titles |>
  filter(is.na(title))


write_csv(missing_titles, 'uk_statements.csv')
