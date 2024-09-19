library(tidyverse)

raw_links_data = read_csv("scrapping_linked_pages.csv")

has_pdf = raw_links_data |> 
  mutate(pdf_ind = ifelse(str_detect(scrape_this_url, ".pdf"), TRUE, FALSE))

splits = split(has_pdf, has_pdf$pdf_ind)

names(splits) = c('webpages', 'are_pdfs')


dir.create('webpages_data')


write_csv(splits$webpages, 'webpages_data/webpage_links.csv')

write_csv(splits$are_pdfs, 'webpages_data/pdf_links.csv')


pdfs = splits$are_pdfs |> 
  mutate(filename = basename(scrape_this_url))

write_csv(pdfs, 'webpages_data/pdf_links.csv')



map2(pdfs$scrape_this_url, pdfs$filename, \(link,name) download.file(link, paste0('raw_pdfs', '/', name)))

tem = tempfile(fileext = '.pdf')

download.file(pdfs$scrape_this_url[1], tem)