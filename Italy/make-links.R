pacman::p_load(rvest, polite, tidyverse)


if(!dir.exists("past_presidents"){
dir.create("past_presidents")



base_url = "https://www.sitiarcheologici.palazzochigi.it/"


past_presidents_sites = read_html(base_url) |> 
  html_elements(xpath = '//*[@id="block-system-main"]/div/div/div/div/div[1]/div/div[2]/div/div/div/div/dl/dt[1]/a') |> 
  html_attr('href') |>
  as_tibble()


xpath_prefix = '//*[@id="block-system-main"]/div/div/div/div/div[1]/div/div[2]/div/div/div/div/dl/dt'

xpath_suffix = '/a'

## lets just make this a vector there are fifteen 

full_xpath = paste0(xpath_prefix, "[", seq(1,15,1), "]", xpath_suffix)


scrape_sites = \(links, path){
  
  scrappy  = rlang::englue('{path}')
  
  
  links_dat = read_html(links) |> 
    html_elements(xpath = scrappy) |> 
    html_attr('href') |> 
    as_tibble() |> 
    rename(site = value) |> 
    mutate(fixed_site = paste0('https://www.sitiarcheologici.palazzochigi.it/', site))
  
  president = read_html(links) |> 
    html_elements(xpath = scrappy) |> 
    html_text() |> 
    as_tibble() |> 
    rename(president = value)
  
  all_info = bind_cols(links_dat, president)
  
  return(all_info)
  
}

archived_sites = map2(base_url, full_xpath, \(x,y) scrape_sites(x,y)) |> 
  list_rbind()


test = read_html(archived_sites[[2,2]]) |> 
  html_elements('.sito_governo_p a') |> 
  html_attr('href') 


get_all_links = \(links, scrappy = '.sito_governo_p a'){
  
  scrappy  = rlang::englue('{scrappy}')
  
  
  links_dat = read_html(links) |> 
    html_elements(scrappy) |> 
    html_attr('href') |> 
    as_tibble() |> 
    rename(site = value) 
  

  links_dat = bind_cols(links_dat, url = links)
  
  return(links_dat)
    
}

pos_links = possibly(get_all_links)

all_links = map(archived_sites$fixed_site, get_all_links) 


### cool now lets go and just grab the news data from the sites 

## lol its berlusconi

join_in = archived_sites |> 
  select(url = fixed_site, president)

all_links_dat = list_rbind(all_links) |> 
  left_join(join_in, join_by(url)) |> 
  select(-url)


### it looks like the onlying I need to add is basicall 

news_suffix = 'notizie-presidente.html'

news_links = all_links_dat |> 
  mutate(news_site = paste0(site, news_suffix), 
         id = row_number()) 

fix_links = news_links |> 
  filter(id >= 9 ) |> 
  mutate(fix_site = str_remove(site, "index.html"),
         news_site = paste0(fix_site, "servizi/comunicati/index.html"),
         news_site = case_when(id == 9 ~ "https://www.sitiarcheologici.palazzochigi.it/www.governo.it/maggio%202008/www.governo.it/Notizie/Palazzo%20Chigi/index.html",
                               id == 8 ~ 'https://www.sitiarcheologici.palazzochigi.it/www.governo.it/maggio%202007/www.governo.it/notizie/not_Archivio.html',
                               .default = news_site)) |> 
  select(id, news_site)

## the pattern should be a=year&m=month number

fixed_links = news_links |> 
  left_join(fix_links, join_by(id)) |> 
  mutate(news_site = coalesce(news_site.y, news_site.x)) |> 
  select(-news_site.x, -news_site.y) |> 
  select(president, news_site)


named_list = split(fixed_links, fixed_links$president)

names_vec = names(named_list)

map(names_vec, \(x) dir.create(paste0("past_presidents/", x, "_statements")))

map2(named_list, names_vec,\(x,y) write_csv(x, paste0("past_presidents/", y, "_statements/", y, "_links.csv")))

}else{


## cool now that we have a lot of 

names_vec = str_remove(names_vec, "-")

names_vec

names_vec = str_replace_all(names_vec, " ", "_")  |> 
  str_replace_all("__", "_") |> 
  str_replace_all("'", "_") |> 
  str_to_lower()


names(named_list) = names_vec

list2env(named_list, .GlobalEnv)


to.remove = ls() |> 
  as_tibble() |> 
  filter(str_detect(value, 'governo', negate = TRUE)) |> 
  deframe()


rm(list = to.remove)

objects = ls()




### ugh long story short basically they gave you a little hope by having some predicitability
## the issue is that they vary other parts of the links even for the older websites 



amato_links = 'http://www.sitiarcheologici.palazzochigi.it/www.governo.it/giugno%202001/www.governo.it/servizi/comunicati/index.html'
  

berlusconi_two_links =  'https://www.sitiarcheologici.palazzochigi.it/www.governo.it/dicembre%202002/www.governo.it/servizi/comunicati/indexea27.html?a=2001'


berlusconi_2006_links = 'https://www.sitiarcheologici.palazzochigi.it/www.governo.it/maggio%202006/www.governo.it/notizie/not_archivio0426.html?pag=1'


governo_berlusconi_iv_links = 'https://www.sitiarcheologici.palazzochigi.it/www.governo.it/novembre%202011/www.governo.it/Notizie/Palazzo%20Chigi/index2bff.html?a=&m=&pg=1'



governo_conte_i_links = 'https://www.sitiarcheologici.palazzochigi.it/www.governo.it/settembre%202019/it/notizie-presidente.html'



governo_conte_ii_links = 'https://www.sitiarcheologici.palazzochigi.it/www.governo.it/febbraio%202021/it/notizie-chigi.html'

governo_d_alema_governo_d_alema_ii_links = 'https://www.sitiarcheologici.palazzochigi.it/www.governo.it/settembre%201999/www.governo.it/servizi/comunicati/index032f.html?a=1998&m=1'

governo_d_alema_ii_governo_amato_ii_links = 'https://www.sitiarcheologici.palazzochigi.it/www.governo.it/ottobre%202000/www.governo.it/servizi/comunicati/indexbd4c.html?a=1999&m=1'

governo_draghi_links = 'https://www.sitiarcheologici.palazzochigi.it/www.governo.it/ottobre2022/www.governo.it/it/notizie-presidente.html'

governo_gentiloni_links = 'https://www.sitiarcheologici.palazzochigi.it/www.governo.it/giugno%202018/notizie-presidente.html'

governo_letta_links = 'https://www.sitiarcheologici.palazzochigi.it/www.governo.it/febbraio%202014/www.governoletta.it/Notizie/Palazzo%20Chigi/index.html'

governo_monti_links = 'https://www.sitiarcheologici.palazzochigi.it/www.governo.it/aprile%202013/www.governo.it/Notizie/Palazzo%20Chigi/index.html'

governo_prodi_governo_d_alema_links = 'https://www.sitiarcheologici.palazzochigi.it/www.governo.it/dicembre%201997/www.governo.it/istituz/pcm.html'

governo_prodi_ii_links = 'https://www.sitiarcheologici.palazzochigi.it/www.governo.it/maggio%202008/www.governo.it/Notizie/Palazzo%20Chigi/index.html'


governo_renzi_links = 'https://www.sitiarcheologici.palazzochigi.it/www.governo.it/febbraio%202015/www.governo.it/Notizie/Palazzo%20Chigi/index.html'

governo_renzi_links = 'https://www.sitiarcheologici.palazzochigi.it/www.governo.it/dicembre%202016/www.governo.it/notizie-chigi.html'


to_keep = ls() |> 
  as_tibble() |> 
  filter(str_detect(value ,'_links', negate = TRUE)) |> 
  deframe()


rm(fixed_links)

save_these = ls()

saving_data = do.call(rbind, mget(save_these)) |> 
  as.data.frame.table() |> 
  distinct(Var1, .keep_all = TRUE) |> 
  slice(-16) |> 
  select(president = Var1, url = Freq)

fix_presidents = saving_data |> 
  mutate(president = case_when(president == 'amato_links' ~ 'governo_amato_links',
                               president == 'berlusconi_2006_links' ~ 'governo_berlusconi_2006_links',
                               president == 'berlusconi_two_links' ~ 'governo_berlusconi_two_links',
                               .default = president),
         names = str_extract(president, '(?<=_)[^_]+(?=_)'),
         id = row_number(),
         names = case_when(id == 7 ~ "Alema",
                           id == 8 ~ "Alema/Amato",
                           id == 13 ~ "Prodi/Alema",
                           .default = names)) |> 
  select(president = names, url)



write_csv(fix_presidents, 'past_presidents/president_links.csv')
}

