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

AMLO = c(1:195)

AMLO = data.frame(AMLO)

AMLO$AMLO = as.character(AMLO$AMLO)

AMLO$URL = "https://www.gob.mx/presidencia/es/archivo/articulos?category=764&filter_origin=archive&idiom=es&order=DESC&page="

AMLO$URLcomplete = paste(AMLO$URL, AMLO$AMLO)

AMLO[3] <- data.frame(lapply(AMLO[3], function(x) {gsub("&page= ", "&page=", x)}))


urls <- c(AMLO$URLcomplete)

urls


nav_df = tibble(urls)
nav_df


# With the list of URLs for each of the results I scrapte each results page.


nav_results_list <- tibble(
  html_results = map(nav_df$urls,
                     ~ {
                       ## If you remove the brackets you can scrape the whole thing.
                       Sys.sleep(2)
                       # As you probably watched in the video, some websites have "antiscraping" protections. So always try to include 
                       # a line of code like the one above to create pauses between every page you are scraping.
                       .x %>%
                         read_html()
                     }),
  summary_url = nav_df$urls
)

nav_results_list

# Now that I have scraped the html information for each page[in this case the first 2 only] I go back 
# to the website and inspect again the structure of the html to tell R what piece of html code to look for.

# The following code tells R what pieces I want and how I want to them.


results_by_page <- tibble(summary_url = nav_results_list$summary_url, 
                          url = 
                            map(nav_results_list$html_results,  
                                ~ .x %>%
                                  html_nodes("a") %>% # This first part asks for the URL to each article
                                  html_attr("href")),
 )

results_by_page 


results_by_page %>% 
  unnest(cols = c(url)) 




# results are contained in a nested list, so I need to unnest it to create a lsit or URLs to each article.

articles_list <- results_by_page %>% 
  unnest(cols = c(url)) 

articles_list[2] <- data.frame(lapply(articles_list[2], function(x) {gsub("\"/", "/", x)}))
articles_list[2] <- data.frame(lapply(articles_list[2], function(x) {gsub('\\\\/', '/', x)}))
articles_list[2] <- data.frame(lapply(articles_list[2], function(x) {gsub('\\\\"', '\\\\', x)}))
articles_list[2] <- data.frame(lapply(articles_list[2], function(x) {gsub('\\\\', '', x)}))

# drop urls to pagination
articles_list = articles_list[!grepl("DESC", articles_list$url),]

articles_list = articles_list[grepl("conferencia-de-prensa", articles_list$url),]


# Again I have the branch of the URL to each article. I need to create complete URLs
urls_articles = articles_list %>%
  mutate(full_url = glue::glue("https://www.gob.mx{url}")) %>%
  select(full_url)


# Now I have a list of URLs to each article and need to scrape each article.
articles <- tibble(
  html_results = map(urls_articles$full_url,
                     ~ {
                       # Again, due to time constrains I will only scrape the first 5.
                       Sys.sleep(2)
                       # Remember to avoid antiscraping protections.
                       .x %>%
                         read_html()
                     }),
  summary_url = urls_articles$full_url
)
articles


beep(8)



# I need to go back again to the website to inspect the structure of the articles and tell R what pieces I want.
articles_text <- tibble(summary_url = articles$summary_url, 
                        text =
                            map(articles$html_results,
                                ~ .x %>%
                                  html_nodes(".article-body") %>%
                                  html_text()),
                       title =
                          map(articles$html_results,
                              ~ .x %>%
                                html_nodes(".bottom-buffer") %>%
                                html_text()),
                     date =
                          map(articles$html_results,
                              ~ .x %>%
                                html_nodes("section p") %>%
                                html_text()),
)
articles_text

######## I have scraped the info I want but it is nested. I unnest the data to have a more useful dataframe.


articles_text <- articles_text %>% 
  unnest(cols = c(title, text, date)) 

# Change date format


articles_text[4] <- data.frame(lapply(articles_text[4], function(x) {gsub("Presidencia de la República", "", x)}))
articles_text[4] <- data.frame(lapply(articles_text[4], function(x) {gsub("\\|", "", x)}))
articles_text[4] <- data.frame(lapply(articles_text[4], function(x) {gsub("  ", "", x)}))


newsconferences = articles_text


newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub("de ", "", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" enero ", "/1/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" febrero ", "/2/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" marzo", "/3/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" abril", "/4/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" mayo", "/5/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" junio", "/6/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" julio", "/7/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" agosto", "/8/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" septiembre", "/9/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" octubre", "/10/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" noviembre", "/11/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" diciembre", "/12/", x)}))
newsconferences[4] <- data.frame(lapply(newsconferences[4], function(x) {gsub(" ", "", x)}))



library(lubridate)

newsconferences <- newsconferences %>%
  mutate(date = lubridate::dmy(date))


#Save docs into a CSV file
write.csv(newsconferences, file = "MexicoAMLO202019-2023.csv")
