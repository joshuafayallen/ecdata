#### Webcraping EPN Press Releases
#### Juan S. Gómez Cruces
#### 2/24/2023


library(tidyverse)
library(rvest)
library(beepr)
library("anytime") 



setwd("C:/Users/Juan/OneDrive - Georgia State University/NSF Work")


#### 
###  Urls to scrape

BORIC = c(1:28)

BORIC = data.frame(BORIC)

BORIC$BORIC = as.character(BORIC$BORIC)

BORIC$URL = "https://prensa.presidencia.cl/comunicados.aspx?page="

BORIC$URLcomplete = paste(BORIC$URL, BORIC$BORIC)

BORIC[3] <- data.frame(lapply(BORIC[3], function(x) {gsub("page= ", "page=", x)}))


urls <- c(BORIC$URLcomplete)
urls


nav_df = tibble(urls)
nav_df



nav_results_list <- tibble(
  html_results = map(nav_df$urls,
                     ~ {
                       Sys.sleep(2)
                       .x %>%
                         read_html()
                     }),
  summary_url = nav_df$urls
)

nav_results_list



results_by_page <- tibble(summary_url = nav_results_list$summary_url, 
                          url = 
                            map(nav_results_list$html_results,  
                                ~ .x %>%
                                  html_nodes("h3 a") %>%
                                  html_attr("href")),
 )

results_by_page 


results_by_page %>% 
  unnest(cols = c(url)) 




articles_list <- results_by_page %>% 
  unnest(cols = c(url)) 


urls_articles = articles_list %>%
  mutate(full_url = glue::glue("https://prensa.presidencia.cl/{url}")) %>%
  select(full_url)


articles <- tibble(
  html_results = map(urls_articles$full_url,
                     ~ {

                       Sys.sleep(2)
                       .x %>%
                         read_html()
                     }),
  summary_url = urls_articles$full_url
)
articles



articles_text <- tibble(summary_url = articles$summary_url, 
                        text =
                            map(articles$html_results,
                                ~ .x %>%
                                  html_nodes(".texto-bloque") %>%
                                  html_text()),
                       title =
                          map(articles$html_results,
                              ~ .x %>%
                                html_nodes("#main_ltTitulo") %>%
                                html_text()),
                     date =
                          map(articles$html_results,
                              ~ .x %>%
                                html_nodes("#main_ltFEcha") %>%
                                html_text()),
)
articles_text

######## I have scraped the info I want but it is nested. I unnest the data to have a more useful dataframe.


articles_text <- articles_text %>% 
  unnest(cols = c(title, text, date)) 



articles_text[2] <- data.frame(lapply(articles_text[2], function(x) {gsub("Ir a Discurso","", x)}))
articles_text[2] <- data.frame(lapply(articles_text[2], function(x) {gsub("Exportar a PDF","", x)}))
articles_text[2] <- data.frame(lapply(articles_text[2], function(x) {gsub("\r\n                                \r\n                                    ","", x)}))
articles_text[2] <- data.frame(lapply(articles_text[2], function(x) {gsub(".*\r\n                                \r\n\r\n"," ", x)}))
articles_text[2] <- data.frame(lapply(articles_text[2], function(x) {gsub("    ","", x)}))



newsconferences = articles_text


newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" ENE ", "/1/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" FEB ", "/2/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" MAR ", "/3/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" ABR ", "/4/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" MAY ", "/5/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" JUN ", "/6/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" JUL ", "/7/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" AGO ", "/8/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" SEP ", "/9/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" OCT ", "/10/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" NOV ", "/11/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" DIC ", "/12/", x)}))



library(lubridate)

newsconferences <- newsconferences %>%
  mutate(date = lubridate::dmy(date))


write.csv(newsconferences, file = "ChileBORIC2022-2023.csv")



############### Piñera Press Releases ################
############### Piñera Press Releases ################
############### Piñera Press Releases ################


PIÑERA = c(1:184)

PIÑERA = data.frame(PIÑERA)

PIÑERA$root = "https://prensa.presidencia.cl/busqueda-avanzada.aspx?page="

PIÑERA$branch = "&desde=01/01/2014&hasta=11/03/2022&sec=comunicado"

PIÑERA$URL = paste(PIÑERA$root, PIÑERA$PIÑERA, PIÑERA$branch)

PIÑERA[4] <- data.frame(lapply(PIÑERA[4], function(x) {gsub(" ", "", x)}))

urls <- c(PIÑERA$URL)
urls


nav_df = tibble(urls)
nav_df


# With the list of URLs for each of the results I scrapte each results page.


nav_results_list <- tibble(
  html_results = map(nav_df$urls,
                     ~ {

                       Sys.sleep(2)
    
                       .x %>%
                         read_html()
                     }),
  summary_url = nav_df$urls
)

nav_results_list




results_by_page <- tibble(summary_url = nav_results_list$summary_url, 
                          url = 
                            map(nav_results_list$html_results,  
                                ~ .x %>%
                                  html_nodes(".texto-busqueda a") %>% 
                                  html_attr("href")),
)

results_by_page 


results_by_page %>% 
  unnest(cols = c(url)) 


articles_list <- results_by_page %>% 
  unnest(cols = c(url)) 


articles_list = articles_list %>%
  filter(!duplicated(cbind(url)))

urls_articles = articles_list %>%
  mutate(full_url = glue::glue("https://prensa.presidencia.cl/{url}")) %>%
  select(full_url)


articles <- tibble(
  html_results = map(urls_articles$full_url,
                     ~ {
                       # Again, due to time constrains I will only scrape the first 5.
                       Sys.sleep(2)

                       .x %>%
                         read_html()
                     }),
  summary_url = urls_articles$full_url
)
articles



articles_text <- tibble(summary_url = articles$summary_url, 
                        text =
                          map(articles$html_results,
                              ~ .x %>%
                                html_nodes(".texto-bloque") %>%
                                html_text()),
                        title =
                          map(articles$html_results,
                              ~ .x %>%
                                html_nodes("#main_ltTitulo") %>%
                                html_text()),
                        date =
                          map(articles$html_results,
                              ~ .x %>%
                                html_nodes("#main_ltFEcha") %>%
                                html_text()),
)
articles_text

articles_text <- articles_text %>% 
  unnest(cols = c(title, text, date)) 



articles_text <- articles_text %>% 
  unnest(cols = c(title, text, date)) 



articles_text[2] <- data.frame(lapply(articles_text[2], function(x) {gsub("Ir a Discurso","", x)}))
articles_text[2] <- data.frame(lapply(articles_text[2], function(x) {gsub("Exportar a PDF","", x)}))
articles_text[2] <- data.frame(lapply(articles_text[2], function(x) {gsub("\r\n                                \r\n                                    ","", x)}))
articles_text[2] <- data.frame(lapply(articles_text[2], function(x) {gsub(".*\r\n                                \r\n\r\n"," ", x)}))
articles_text[2] <- data.frame(lapply(articles_text[2], function(x) {gsub("    ","", x)}))



newsconferences = articles_text


newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" ENE ", "/1/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" FEB ", "/2/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" MAR ", "/3/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" ABR ", "/4/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" MAY ", "/5/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" JUN ", "/6/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" JUL ", "/7/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" AGO ", "/8/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" SEP ", "/9/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" OCT ", "/10/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" NOV ", "/11/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" DIC ", "/12/", x)}))



library(lubridate)

newsconferences <- newsconferences %>%
  mutate(date = lubridate::dmy(date))


#Save docs into a CSV file
write.csv(newsconferences, file = "Chile{BORICPIÑERA2018-2022.csv")


