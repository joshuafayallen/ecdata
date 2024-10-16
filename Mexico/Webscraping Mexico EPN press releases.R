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

EPN = c(1:100)

EPN = data.frame(EPN)

EPN$URL = "https://www.gob.mx/epn/es/archivo/prensa?idiom=es&order=DESC&page="






urls <- c("",
          "https://www.presidency.ucsb.edu/documents/app-categories/presidential/news-conferences?page=1", 
"https://www.presidency.ucsb.edu/documents/app-categories/presidential/news-conferences?page=2", 
"https://www.presidency.ucsb.edu/documents/app-categories/presidential/news-conferences?page=3", 
"https://www.presidency.ucsb.edu/documents/app-categories/presidential/news-conferences?page=4",
"https://www.presidency.ucsb.edu/documents/app-categories/presidential/news-conferences?page=5")

urls


nav_df = tibble(urls)
nav_df


# With the list of URLs for each of the first 5 results, now I scrape all the 5 pages.


nav_results_list <- tibble(
  html_results = map(nav_df$urls,
                     ~ {
                       # Since scraping 5  pages would take a while, I will only scrape the first 2. 
                       # If you remove the brackets you can scrape the whole thing.
                       Sys.sleep(2)
                       # As you probably watched in the video, some websites have "antiscraping" protections. So always try to include 
                       # a line of code like the one above to create pauses between every page you are scraping.
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
                                  html_nodes(".field-title a") %>% 
                                  html_attr("href")),
                          name =
                            map(nav_results_list$html_results,
                                ~ .x %>%
                                  html_nodes(".field-title a") %>% # Second  part asks for the title of each article
                                  html_text())
)

results_by_page 
.

articles_list <- results_by_page %>% 
  unnest(cols = c(url, name)) 



urls_articles = articles_list %>%
  mutate(full_url = glue::glue("https://www.presidency.ucsb.edu{url}")) %>%
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


beep(8)


articles_text <- tibble(summary_url = articles$summary_url, 
                        text =
                            map(articles$html_results,
                                ~ .x %>%
                                  html_nodes(".field-docs-content") %>%
                                  html_text()),
                        date =
                          map(articles$html_results,
                              ~ .x %>%
                                html_nodes(".date-display-single") %>%
                                html_text()),
                        title =
                          map(articles$html_results,
                              ~ .x %>%
                                html_nodes("h1") %>%
                                html_text()),
                        president =
                          map(articles$html_results,
                              ~ .x %>%
                                html_nodes(".diet-title a") %>%
                                html_text()),
)
articles_text




articles_text <- articles_text %>% 
  unnest(cols = c(title, text, date, president)) 




newsconferences = articles_text

newsconferences$date <- anydate(newsconferences$date)


newsconferences$doctype = "News Conferences"



write.csv(articles_text, file = "newsconferences.csv")



newsconferences <- read.csv("newsconferences.csv")
