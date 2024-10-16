#### EAP: EX COMM ####

### THIS CODE IS MADE TO CREATE THE FUNCTION TO WEBSCRAP INFORMATION FROM COSTA RICA EXE COMM ###
# Setup
rm(list=ls())

# set wd
setwd("/Users/jaimelindh/Dropbox/1. UNC/4. RA/Executive Approval/Paper Dataset/costa rica")

library(tidyverse)  
library(rvest)      
library(stringr)    
library(lubridate)  
library(tictoc)
library(dplyr)
library(stringi)


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



f.all <- function(html){ 
  tibble(
    date = f.date(html),
    title = f.title(html),
    text = f.text(html)
    )
  }


f.extract_urls <- function(page) { 
  page %>%
    html_elements("#contentInfo") %>%
    html_elements("a") %>%
    html_attr("href") %>%
    paste0("https://www.presidencia.go.cr", .)
}


f.main.extract <- function(url_noticias) {
  
  all_urls <- 
    url_noticias %>% 
    read_html() %>%
    f.extract_urls(.) %>%
    unlist()
  
  all_htmls <- all_urls %>%
    map(~ {
      Sys.sleep(runif(1, 0.05, 0.1))
      read_html(.)
    })
  
  all_htmls %>% 
    map_dfr(~ {
      Sys.sleep(runif(1, 0.05, 0.1))
      f.all(.)
    })
}



url_noticias <- "https://www.presidencia.go.cr/noticias"

tic()
data <- f.main.extract(url_noticias)
toc()

data <- data %>%
  mutate(text_cleaned = trimws(text)) %>%
  filter(text_cleaned !="")


df <- data %>%
  group_by(title) %>%
  mutate(exe_com = ifelse(any(grepl("presidente de la republica|chaves", text, ignore.case = TRUE)), 1, 0)) %>%
  filter(exe_com==1) %>%
  select(date, title, text) %>%
  mutate(type = "press release",
         speaker = "president") %>%
   ungroup()


write.csv(df, "exe_com_costarica.csv")





