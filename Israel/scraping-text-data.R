library(tidyverse) 
library(rvest)
library(xml2)


webpages = read_csv("links_from_landing_to_scrape.csv")

if(!dir.exists("webpages")){
dir.create("webpages")
  
}
else{
  print('This directory already exists')
}

introduce =  "This crawler is a part of an National Science Foundation Funded project. For any questions about the project please contact Ryan Carlin at rcarlin@gsu.edu. \n For any questions about the crawler please contact Josh Allen at jallen108@gsu.edu"

save_webpage = \(link, pattern = "(?<=news/)(.*)", agent = NULL){
  if(is.null(agent)){
      warning(paste("Please set a user agent"))
  
  link_pat = rlang::englue("{pattern}")
  
    name_page = str_extract(link, link_pat)
  
    links_in = read_html(link)
  
    write_html(links_in, here::here("webpages", paste0(name_page,".html")))
  
    sleep_time = sample(5:15, size = 1)
  
    cat("Done Saving", link, "\n", "sleeping for", sleep_time)
  
    names_tibble = tibble(url = link,
                        name = name_page)
  Sys.sleep(sleep_time)
  }else{
  
    user = rlang::englue("{agent}")
  
    polite::bow(link, user_agent = user)
  
    link_pat = rlang::englue("{pattern}")
  
    name_page = str_extract(link, link_pat)
  
    links_in = read_html(link)
  
    write_html(links_in, here::here("webpages", paste0(name_page,".html")))
  
    names_tibble = tibble(url = link,
                        name = name_page)
  sleep_time = sample(5:15, size = 1)
    
  cat("Done Saving", link, "\n", "sleeping for", sleep_time)
    
  Sys.sleep(sleep_time)
  }

return(names_tibble)
}

## these were neccessary for me but may not be for you

save_vec = webpages$links


map(save_vec, \(x) save_webpage(link = x, agent = introduce))

length(save_vec)

save_vec2 = save_vec[3328:9947]

map(save_vec2, \(x) save_webpage(link = x, agent = introduce))

length(save_vec2)

save_vec3 = save_vec2[2139:6620]


map(save_vec3, \(x) save_webpage(link = x, agent = introduce))

check_vec = c(save_vec,save_vec2, save_vec3)

check = webpages |>
filter(!links %in% check_vec)

library(furrr)

plan(multisession, workers = 10)


scrapping_webpages = \(links, source){




  text_dat = read_html(links) |>
  html_elements("#NewsContent p") |>
  html_text() |>
  as_tibble() |>
  rename(text = value)
  
  subject_dat = read_html(links) |>
  html_elements("#NewsTitle") |>
  html_text() |>
  as_tibble() |>
  rename(subject = value)
  
  date_dat = read_html(links) |>
  html_elements("#cmd_publishDate_1") |>
  html_text() |>
  as_tibble() |>
  rename(date = value)
  
  bound_dat = bind_cols(date_dat, subject_dat, text_dat, url = source)
  
  return(bound_dat)
  }


  htmls = list.files(path = "webpages", pattern = "*.html", full.names = TRUE)

  links = read_csv('links_from_landing_to_scrape.csv')
  
  
  

  htmls_tib = tibble(files = htmls) |>
    mutate(files_sans_path = str_remove(files, 'webpages/'))
  
  links_with_names = links |>
    mutate(file_names = str_extract(links, "(?<=news/)(.*)"))
  
  bring_file_names = links_with_names  |>
    left_join(htmls_tib, join_by(file_names == files_sans_path)) |>
    mutate(files = paste0('webpages/', file_names, '.html')) |>
    select(links, files)


  scrapping_webpages = \(links, source){




    text_dat = read_html(links) |>
    html_elements("#NewsContent p") |>
    html_text() |>
    as_tibble() |>
    rename(text = value)
    
    subject_dat = read_html(links) |>
    html_elements("#NewsTitle") |>
    html_text() |>
    as_tibble() |>
    rename(subject = value)
    
    date_dat = read_html(links) |>
    html_elements("#cmd_publishDate_1") |>
    html_text() |>
    as_tibble() |>
    rename(date = value)
    
    bound_dat = bind_cols(date_dat, subject_dat, text_dat, url = source)
    
    return(bound_dat)
    }
  
  add_sources = future_map2(bring_file_names$files, bring_file_names$links, \(x,y) scrapping_webpages(link = x, source = y))
  
  bound_together = add_sources |>
    list_rbind() |>
    mutate(subject = str_squish(subject))
  
  
  parse_date = bound_together |>
    mutate(date = dmy(date))
  
  write_csv(parse_date, 'israel_statements.csv')
  