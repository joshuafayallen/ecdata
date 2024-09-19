pacman::p_load(rvest, tidyverse)

if(dir.exists('statement_data')){
  print('This already exists')
}else{

dir.create('statement_data')
}

links_raw = read_csv('links.csv')


processed_data = links_raw |> 
  mutate(speaker = str_squish(speaker)) |> 
  filter(speaker %in% c('Presidenza', 'Presidente CdM'))



subject = read_html_live("https://www.sitiarcheologici.palazzochigi.it/www.governo.it/giugno%202001/www.governo.it/servizi/comunicati/dettaglio0cfd.html?d=9036") |>
  html_elements('body > center > table > tbody > tr:nth-child(2) > td:nth-child(2) > table > tbody > tr:nth-child(2) > td > span:nth-child(4)') |> 
  html_text() |> 
  as_tibble()



 text =  
  read_html_live("https://www.sitiarcheologici.palazzochigi.it/www.governo.it/giugno%202001/www.governo.it/servizi/comunicati/dettaglio0cfd.html?d=9036") |> 
  html_elements(xpath = '/html/body/center/table/tbody/tr[2]/td[2]/table/tbody/tr[2]/td/p[2]/span') |> 
  html_text() |> 
  as_tibble() |> 
  separate_longer_delim(value, delim = '\n') |> 
  mutate(value = str_remove(value, '-'))

bind_cols(subject, text)

res = robotstxt::get_robotstxt("https://www.sitiarcheologici.palazzochigi.it/www.governo.it/giugno%202001/www.governo.it")

# this gives us a different answer just based on how 
# polite handles domain names

polite::bow(processed_data[[1,3]])


scrapper = \(links, identity = 'For questions or comments please contact Ryan Carlin at rcarlin@gsu.edu'){

  ag = rlang::englue('{identity}') 
   
  ## this will return a false but if we do 
  ## robotstxt::get_robotstxt(robotstxt::get_robotstxt("https://www.sitiarcheologici.palazzochigi.it/www.governo.it/giugno%202001/www.governo.it")

  session = polite::bow(links, user_agent = ag)

  subject = read_html_live(links) |> 
    html_elements('body > center > table > tbody > tr:nth-child(2) > td:nth-child(2) > table > tbody > tr:nth-child(2) > td > span:nth-child(4)') |> 
  html_text() |> 
  as_tibble() |> 
    rename(subject = value)


  text = read_html_live(links) |> 
  html_elements(xpath = '/html/body/center/table/tbody/tr[2]/td[2]/table/tbody/tr[2]/td/p[2]/span') |> 
  html_text() |> 
  as_tibble() |> 
  separate_longer_delim(value, delim = '\n') |> 
  mutate(value = str_remove(value, '-')) |> 
    rename(text = value)

if(nrow(subject) == 0){

 subject = read_html_live(links) |> 
   html_elements('body > center > table > tbody > tr:nth-child(2) > td:nth-child(2) > table > tbody > tr:nth-child(2) > td > span:nth-child(6) > b') |> 
   html_text() |> 
   as_tibble() |> 
   rename(subject = value)


 bound_data = bind_cols(url = links, subject,
                     text)
}else{

bound_data = bind_cols(subject, text, url = links)
}
  
  if(nrow(bound_data) != 0){
    cat(links, " This worked! Sleeping now", "\n")
  }else{
    cat(links, 'This did not work :(')
    failed_links <<- tibble(links_to_check = links)
  }
  

  Sys.sleep(runif(1, min = 5, max = 5))
  
  
  return(bound_data)
  

}

scrapper(links = 'https://joshuafayallen.github.io/')


test = map(fake_links$links, \(x) scrapper(x))

test_dat = slice_sample(processed_data, n = 5) |> 
  pull('url')


test_list = map(test_dat, \(x) scrapper(links = x))


list_rbind(test_list) -> check

tail(check)


pos_scrapper = possibly(scrapper)

amato_data = map(processed_data$url, \(x) scrapper(links = x)) 


#
failed_links[[1,1]]

scraping_data = failed_links[[1,1]] |> 
  read_html_live() |> 
  html_table(header = TRUE) |> 
  pluck(7)


scrapping_links = tibble(links = c('https://www.sitiarcheologici.palazzochigi.it/www.governo.it/giugno%202001/www.governo.it/servizi/comunicati/dettagliocb55.html?d=9396',
'https://www.sitiarcheologici.palazzochigi.it/www.governo.it/giugno%202001/www.governo.it/servizi/comunicati/dettagliod176.html?d=9359', 
'https://www.sitiarcheologici.palazzochigi.it/www.governo.it/giugno%202001/www.governo.it/servizi/comunicati/dettaglio4a23.html?d=9350',
'https://www.sitiarcheologici.palazzochigi.it/www.governo.it/giugno%202001/www.governo.it/servizi/comunicati/dettaglio8352.html?d=9349'))


supplemental_data = map(scrapping_links$links, \(x) scrapper(x))


amato_bound = list_rbind(amato_data) 

bound_sup = list_rbind(supplemental_data)

full_data = bind_rows(amato_bound, bound_sup)


joining_data = processed_data |> 
  select(url, date) |> 
  distinct(url, .keep_all = TRUE)

add_dates = full_data |> 
  left_join(joining_data, join_by(url)) 


parsing_dates = add_dates |> 
  mutate(date_1 = as_datetime(date),
         missing_date_flag = ifelse(is.na(date_1), TRUE, FALSE),
         date_2 = ifelse(is.na(missing_date_flag), str_squish(date), date),
         date2 = dmy(date_2),
        date = coalesce(date_1, date2),
      date = as_date(date),
    president = 'Amato')  |> 
  select(-missing_date_flag, -matches('\\d+')) 


write_csv(parsing_dates, "statement_data/amato_statements.csv")

