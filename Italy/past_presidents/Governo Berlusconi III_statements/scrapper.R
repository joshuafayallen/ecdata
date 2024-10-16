pacman::p_load(rvest, tidyverse)


berlusc = read_csv('berlusc_three_links.csv')



rel_links = berlusc |> 
  filter(speaker %in% c('Presidente CdM', 'Presidenza'))



date = read_html_live(rel_links[[1,1]]) |> 
  html_elements('#contenuto > table > tbody > tr > td:nth-child(2) > table > tbody > tr:nth-child(4) > td > table > tbody > tr:nth-child(3) > td:nth-child(2) > span') |> 
  html_text()



subject = read_html_live(rel_links[[1,1]]) |>
  html_elements('#contenuto > table > tbody > tr > td:nth-child(2) > table > tbody > tr:nth-child(6) > td > span > b') |> 
  html_text()


text = read_html_live(rel_links[[1,1]]) |>
  html_elements('#contenuto > table > tbody > tr > td:nth-child(2) > table > tbody > tr:nth-child(6) > td > p') |> 
  html_text() |> 
  as_tibble() |> 
  separate_longer_delim(value, delim = '\t')

scrapper = \(links, agent = 'for any questions please contact Ryan carlin'){
   
  ag = rlang::englue('{agent}')
  
  polite::bow(links, user_agent = ag)

text = read_html_live(links) |>
  html_elements('#contenuto > table > tbody > tr > td:nth-child(2) > table > tbody > tr:nth-child(6) > td > p') |> 
  html_text() |> 
  as_tibble() |> 
  separate_longer_delim(value, delim = '\t') |> 
  rename(text = value )
  
  
subject = read_html_live(links) |>
  html_elements('#contenuto > table > tbody > tr > td:nth-child(2) > table > tbody > tr:nth-child(6) > td > span > b') |> 
  html_text() |> 
  as_tibble() |> 
  rename(subject = value)

  date = read_html_live(links) |> 
  html_elements('#contenuto > table > tbody > tr > td:nth-child(2) > table > tbody > tr:nth-child(4) > td > table > tbody > tr:nth-child(3) > td:nth-child(2) > span') |> 
  html_text() |> 
  as_tibble() |> 
   rename(date = value)

  tryCatch({
    bound_dat = bind_cols(text, subject, date, url = links)}, errror = function(e){
    
    conditionMessage(e)
    
    if(grepl('recycled', e, ignore.case = TRUE)){
      cat('This did not work ')
      bad_data <<- tibble(url = links)
    }
  else{
    cat('Something bad happened that wasnt a recyling error')
    bad_data <<- tibble(url = links)
  }
  })

cat("Done Scraping", links, "\n")

  
  Sys.sleep(runif(1, 5, 8))

  return(bound_dat)
}


test_links = berlusc |> 
  slice_sample(n = 3 )

test_list = map(test_links$url, scrapper)

test_list |> 
  list_rbind()

berlusc_iii = map(rel_links$url, \(x) scrapper(x))


berlusc_iii_dat = berlusc_iii |> 
  list_rbind() |> 
  mutate(date = dmy(date))


if(dir.exists('statements')){
  write_csv(berlusc_iii_dat, 'statements/berlusc_iii.csv')
  
}else{
  dir.create('statements')
  write_csv(berlusc_iii_dat, 'statements/berlusc_iii_statements.csv')
}


