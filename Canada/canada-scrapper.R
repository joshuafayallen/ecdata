library(tidyverse)
library(rvest)

raw_dat = read_csv('trudeau_statements.csv')



raw_links = read_csv('trudeau_links.csv')

raw_links$links[1] |>
  read_html() |>
  html_elements('.title-header-inner h1') |>
  html_text()


scrapper = \(links){
  df = read_html(links)|>
    html_elements('.title-header-inner h1') |>
    html_text() |>
    as_tibble() |>
    mutate(url = links)

  Sys.sleep(5)

  return(df)
 
}

get_datas = map(raw_links$links, \(x) scrapper(x))


bound_get_datas = list_rbind(get_datas)


joined_data = raw_dat |>
  left_join(bound_get_datas, join_by(title == value)) |>
  mutate(date = dmy(date))


check = raw_links |>
  filter(is.na(url)) |>
  distinct(title, .keep_all = TRUE)

check_these =  pull(check, title)



fix_statements = raw_links |>
  mutate(url = case_when(
    title == check_these[1] ~ 'https://www.pm.gc.ca/en/news/news-releases/2022/05/12/prime-minister-attends-second-global-covid-19-summit-contribute#:~:text=Canada%20is%20contributing%20to%20the,to%20disease%20outbreaks%20going%20forward.%E2%80%9D',
    title == check_these[2] ~ 'https://www.pm.gc.ca/en/news/speeches/2021/09/29/prime-ministers-remarks-event-first-national-day-truth-and-reconciliation',
    title == check_these[3] ~ 'https://www.pm.gc.ca/en/news/speeches/2021/07/02/prime-ministers-remarks-covid-19-situation-bc-wildfires-and-advancing',
    title == check_these[4] ~ 'https://www.pm.gc.ca/en/news/news-releases/2022/05/12/prime-minister-attends-second-global-covid-19-summit-contribute#:~:text=Canada%20is%20contributing%20to%20the,to%20disease%20outbreaks%20going%20forward.%E2%80%9D',
    title == check_these[5] ~ 'https://www.pm.gc.ca/en/news/speeches/2021/02/16/prime-ministers-remarks-announcing-new-firearms-measures-and-updating',
    title == check_these[6] ~ 'https://www.pm.gc.ca/en/news/speeches/2020/12/11/prime-ministers-remarks-covid-19-and-canadas-strengthened-climate-plan', 
    title == check_these[7] ~ 'https://www.pm.gc.ca/en/news/speeches/2020/10/06/prime-ministers-address-state-funeral-right-honourable-john-n-turner',
    title == check_these[8] ~ 'https://www.pm.gc.ca/en/news/speeches/2020/06/11/prime-ministers-remarks-canada-emergency-wage-subsidy-and-additional',
    title == check_these[9] ~ 'https://www.pm.gc.ca/en/videos/2020/05/25/remarks-opening-canada-emergency-commercial-rent-assistance-program',
    title == check_these[10] ~ 'https://www.pm.gc.ca/en/news/speeches/2020/05/09/prime-ministers-remarks-recent-measures-support-canadians-during-covid-19',
    title == check_these[11] ~ 'https://www.pm.gc.ca/en/news/speeches/2020/04/30/prime-ministers-remarks-updating-canadians-crash-canadian-armed-forces',
    title == check_these[12] ~ 'https://www.pm.gc.ca/en/news/speeches/2020/04/15/prime-ministers-remarks-expansion-canada-emergency-response-benefit-and',
    title == check_these[13] ~ 'https://www.pm.gc.ca/en/news/speeches/2020/04/08/prime-ministers-remarks-support-businesses-and-students-affected-covid-19',
    title == check_these[14] ~ 'https://www.pm.gc.ca/en/news/speeches/2020/03/27/prime-ministers-remarks-announcing-additional-support-small-and-medium',
    title == check_these[15] ~ 'Prime Minister’s remarks announcing the COVID-19 Economic Response Plan',
    .default = url
  ))



write_csv(fix_statements, 'canada_statements.csv')



