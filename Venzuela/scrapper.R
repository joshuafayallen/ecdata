pacman::p_load(arrow,xml2, furrr ,rvest, tidyverse)

links = read_parquet('statement_links.parquet')

dedup = links |>
  distinct(links, .keep_all = TRUE)

## instead of scraping the data we should just write the htmls 

dir.create('webpages')

make_request_links = dedup |>
  mutate(ids = str_extract(links, '\\d{5}'))


req = request("https://www.presidencia.gob.ve/Site/Web/Principal/paginas/classMostrarEvento3.php") |> 
  req_url_query(
    id_evento = make_request_links$ids[2],
  ) |> 
  req_headers(
    Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
    `Accept-Language` = "en-US,en;q=0.9",
    `Cache-Control` = "max-age=0",
    Cookie = "PHPSESSID=6db8p3vt4j83ldcqhsniualhv5",
    `Upgrade-Insecure-Requests` = "1",
    `User-Agent` = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36",
  ) |> 
  req_perform() 

## okay it looks like the easiest way is to just send a post request 

get_htmls = \(ids, title){

  id = rlang::englue('{ids}')

  req = request("https://www.presidencia.gob.ve/Site/Web/Principal/paginas/classMostrarEvento3.php") |> 
    req_url_query(
      id_evento = id,
    ) |> 
    req_headers(
      Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
      `Accept-Language` = "en-US,en;q=0.9",
      `Cache-Control` = "max-age=0",
      Cookie = "PHPSESSID=6db8p3vt4j83ldcqhsniualhv5",
      `Upgrade-Insecure-Requests` = "1",
      `User-Agent` = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36",
    ) |> 
    req_perform() 

resp = req |>
  resp_body_html()
  
  write_html(resp, paste0("webpages/", paste0(title, ".html")))

  Sys.sleep(5)

  cli::cli_alert_success("Successfully Downloaded {title}")


}

## okay this worked 
get_htmls(ids = make_request_links$ids[1], title = make_request_links$subject[1])

pos_fun = possibly(get_htmls)

downloads = map2(make_request_links$ids, make_request_links$subject, \(link, subject) pos_fun(ids = link, title = subject))

issues = which(lengths(downloads) == 0)

rescrape_links = make_request_links |>
 mutate(id  = row_number()) |>
  filter(id %in% issues)

## okay lets just get some data into the dataset for venzuela
rescrapes = map2(rescrape_links$ids, rescrape_links$subject, \(link, subject) pos_fun(ids = link, title = subject))



html_files = list.files(path = 'webpages', pattern = '*.html',full.names = TRUE)

dat = tibble(files = html_files) |>
       mutate(title = basename(files),
              title = str_squish(files),
              title = str_remove_all(files, 'webpages/|.html'))

## check 

joins = make_request_links |>
  left_join(dat, join_by(subject == title)) |>
  filter(!is.na(files))


test = html_files[1]

text = read_html(test) |>
  html_elements('.post_Noti_Princ') |>
  html_text()

scrapper = \(file){
  text = read_html(file)|> 
    html_elements('.post_Noti_Princ') |>
    html_text()

  return(text)
}

plan(multisession, workers = 3)


add_text = joins |>
  mutate(text = future_map_chr(files, \(x) scrapper(x)),
        text = str_squish(text),
       date = dmy(date)) |>
  select(-files, -ids)


write_csv(add_text, 'venzuela_statements.csv')



