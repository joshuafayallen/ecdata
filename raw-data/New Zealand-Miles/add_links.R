library(tidyverse)
library(rvest)

files = list.files(pattern = '*.csv', full.names = TRUE)

links_tib = tibble(urls = files) |>
  filter(str_detect(urls, 'links')) |>
  mutate(type = ifelse(str_detect(urls, 'speech'), 'speech', 'press release'))

files_split = split(links_tib, links_tib$type)


speeches = map(files_split$speech$urls, \(x) read_csv(x))

press_release = map(files_split$`press release`$urls, \(x) read_csv(x))

press_bound = press_release |>
  list_rbind(names_to = 'leader')


speeches_bound = speeches |>
  list_rbind(names_to = 'leader')



links_tib = tibble(urls = files) |>
  filter(str_detect(urls, 'links', negate = TRUE)) |>
  mutate(type = ifelse(str_detect(urls, 'speech'), 'speech', 'press release'))

files_split = split(links_tib, links_tib$type)


speeches_data = map(files_split$speech$urls, \(x) read_csv(x)) |>
  list_rbind()

press_release_data = map(files_split$`press release`$urls, \(x) read_csv(x)) |>
  list_rbind()



subject = read_html(press_bound$links[1]) |>
  html_elements('.article__title') |>
  html_text()


read_html(speeches_bound$links[1]) |>
  html_elements('.article__title') |>
  html_text()

add_links = \(links){
  subject = read_html(links) |>
    html_elements('.article__title') |>
    html_text() |>
    as_tibble() |>
    rename(title = value) |>
    mutate(url = links)

  cat('Done Scraping', links, '\n')
  
  Sys.sleep(5)
  
  return(subject)
   
}

pos_add_links = possibly(add_links)

speeches_links = map(speeches_bound$links, \(x) pos_add_links(x))

release_links = map(press_bound$links, \(x) pos_add_links(x))

rescrape_speeches = which(lengths(speeches_links) == 0)

release_links_rescrape = which(lengths(release_links) == 0)

press_bound_rescrape = press_bound |>
  mutate(id = row_number()) |>
  filter(id == 494)

rescraped= pos_add_links(press_bound_rescrape$links)

speeches_bound = list_rbind(speeches_links)

press_bound = list_rbind(release_links) |>
  bind_rows(rescraped)


joined_speeches = speeches_data |>
  left_join(speeches_bound)


joined_releases = press_release_data |>
  left_join(press_bound)

stacked = bind_rows(joined_speeches, joined_releases) |>
  mutate(date= dmy(date))


write_csv(stacked, 'new_zealand_statements.csv')


## the stupid thing has missing urls 

raw_dat = read_csv('new_zealand_statements.csv')

missing_links = raw_dat |>
  filter(is.na(url)) |>
  distinct(title) |>
  mutate(title = str_squish(title)) |>
  pull(title)

date_st = raw_dat |>
  filter(is.na(url)) |>
  distinct(title, .keep_all = TRUE) |>
  mutate(title = str_squish(title)) |>
  pull(date)

fix_links = raw_dat |>
  mutate(title = str_squish(title),
     fix_urls = case_when(
    title == missing_links[1] ~ 'https://www.beehive.govt.nz/speech/prime-minister%E2%80%99s-speech-china-business-summit',
    title == missing_links[2] ~ 'https://www.beehive.govt.nz/speech/speech-nato-summit-session-indo-pacific-partners',
    title == missing_links[3] ~ 'https://www.beehive.govt.nz/speech/prime-ministers-foreign-policy-speech-nziia',
    title == missing_links[4] ~ 'https://www.beehive.govt.nz/speech/prime-minister-rt-hon-chris-hipkins-peking-university',
    title == missing_links[5] ~ 'https://www.beehive.govt.nz/speech/pre-budget-speech-auckland-27-april'
  ),
        url = coalesce(url, fix_urls)) |>
  select(date:url)


write_csv(fix_links, 'new_zealand_statements.csv')
