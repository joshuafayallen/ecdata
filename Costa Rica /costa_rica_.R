#### EAP: EX COMM ####

### THIS CODE IS MADE TO CREATE THE FUNCTION TO WEBSCRAP INFORMATION FROM COSTA RICA EXE COMM ###
# Setup
rm(list=ls())

# set wd
setwd("/Users/jaimelindh/Dropbox/1.UNC/4. RA/Executive Approval/Paper Dataset/costa rica")

library(tidyverse)  # General-purpose data wrangling
library(rvest)      # Parsing of HTML/XML files  
library(stringr)    # String manipulation
library(lubridate)  # DateTime manipulation
library(tictoc)
library(dplyr)
library(stringi)

# Create functionsurl# Create functions to extract key information of each press release
f.date<-function(html){
  html %>%
    html_nodes("time") %>%
    html_attr("datetime") %>%
    substr(., 1, 10) %>%
    ymd()
}


f.title<-function(html){
  html %>%
    html_element(".active") %>%
    html_text2()
}


f.text <-function(html){
    html %>%
    html_elements("#contentInfo") %>%
    html_elements("p") %>%
    html_text2()
}


# Create function that creates main matrix for each press release
f.all <- function(html){ 
  tibble(
    date = f.date(html),
    title = f.title(html),
    text = f.text(html)
    )
  }

# Function to extract and prepend URLs from a single page (just one page in this case study)
f.extract_urls <- function(page) { 
  page %>%
    html_elements("#contentInfo") %>%
    html_elements("a") %>%
    html_attr("href") %>%
    paste0("https://www.presidencia.go.cr", .)
}

# Main function to perform the scraping
f.main.extract <- function(url_noticias) {
  
  all_urls <- 
    url_noticias %>% 
    read_html() %>%
    f.extract_urls(.) %>%
    unlist()
  
  result <- map2_dfr(all_urls, 
                     all_urls %>% map(read_html), 
                     ~ {
                       Sys.sleep(runif(1, 0.05, 0.1))
                       extracted_data <- f.all(.y)
                       extracted_data$url <- .x
                       extracted_data
                     })
  
  return(result)
  
}



# Perform the webscrapping:
url_noticias <- "https://www.presidencia.go.cr/noticias"

tic()
data <- f.main.extract(url_noticias)
toc()

# Filter out blank rows without text
data <- data %>%
  mutate(text_cleaned = trimws(text)) %>%
  filter(text_cleaned !="")

# Filter out press release that only about executive
df <- data %>%
  group_by(title) %>%
  mutate(exe_com = ifelse(any(grepl("presidente de la republica|chaves", text, ignore.case = TRUE)), 1, 0)) %>%
  filter(exe_com==1) %>%
  select(date, title, text, url) %>%
  mutate(type = "press release",
         speaker = "president") %>%
   ungroup()

# Export to csv
write.csv(df, "exe_com_costarica.csv")





