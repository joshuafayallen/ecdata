library(tidyverse)

statements = list.files(pattern = '*.csv', recursive = TRUE, full.names = TRUE)

statements_tib = tibble(files = statements)



exclude_these = c('./meloni_statements_it.csv', './italian_statements.csv',
"./past_presidents/Governo Monti_statements/data/merged_pdfs.csv",  "./past_presidents/Governo Monti_statements/data/merged_webs.csv",
"./past_presidents/Governo Monti_statements/data/raw_monti_data.csv",
"./past_presidents/Governo Monti_statements/data/raw_monti_pdf.csv",
"./past_presidents/Governo Monti_statements/pdf_files.csv",
"./past_presidents/Governo Monti_statements/scrapping_linked_pages.csv",
"./past_presidents/Governo Monti_statements/test_data.csv",
"./past_presidents/selectors_for_prodi_alema.csv", 
"./italian_statements.csv",
"./all_italian_statements.csv",
"./past_presidents/Governo Amato II_statements-Josh/statement_data/amato_statements.csv")



cleaned_tib = statements_tib |> 
  filter(str_detect(files, 'links', negate = TRUE)) |> 
  filter(!files %in% exclude_these) |> 
  mutate(datas = map(files, read_csv),
         cols  = map_dbl(datas, ncol)) 



big_tibs = cleaned_tib |> 
  filter(cols == 5) |> 
  unnest(datas) |> 
  select(-c(cols, president,speaker))


small_tibs = cleaned_tib |> 
  filter(cols != 5) |> 
  unnest(datas) |> 
  select(-c(cols, speaker)) |> 
  mutate(
        Date = dmy(Date, locale = "it_IT.UTF-8"),
        subject = coalesce(subject, Title),
        url = coalesce(url, links, URL),
        text = coalesce(text, Text),
        date = coalesce(date, Date))  |> 
  select(-c(Title, URL, links, Date, Text))






cleaned_past_presidents = bind_rows(big_tibs, small_tibs) |> 
  mutate(president = str_extract(files, '(?<=Governo).*(?=\\/statements)'),
         pres_two = str_extract(files, '(?<=Governo).*(?=\\-Josh)'),
         pres_three = str_extract(files, '(?<=Governo).*(?=\\/data)' ),
         pres_four = str_extract(files, '(?<=Governo).*(?=\\/conte)'),
         pres_five = str_extract(files, '(?<=Governo).*(?=\\/prodi)'),
         pres_six = str_extract(files, '(?<=Governo).*(?=\\/Prodi)'),
         pres_seven = str_extract(files, '(?<=Governo).*(?=\\/Renzi)'),
        president = coalesce(president, pres_two, pres_three, pres_four,pres_five, pres_six, pres_seven),
         president = str_remove(president, '_statements'),
         president = str_remove(president, '\\b[IVXLCDM]+\\b'),
         president  = str_remove(president, 'II'),
         president = str_squish(president),
         president = case_match(president,
         "'Alema - Governo D'Alema" ~ "Massimo D'Alema",
          "Prodi - Governo 'Alema" ~ "Romano Prodi/Massimo D'Alema",
                                .default = president),
        president = ifelse(str_detect(president,"II"), "Massimo D'Alema/Giuliano Amato", president),
      executive = case_match(president,
      "Amato" ~ "Giuliano Amato",
     "Berlusconi" ~ "Silvio Berlusconi",
     "Conte" ~ "Giuseppe Conte",
    "Draghi" ~ "Mario Draghi",
  "Renzi" ~ "Matteo Renzi",
  "Gentiloni" ~ "Paolo Gentiloni",
  "Letta" ~ "Enrico Letta", 
  "Monti" ~ "Mario Monti",
  "Prodi" ~ "Romano Prodi", .default = president)) |> 
  select(-pres_two, -pres_three, -pres_four, -pres_five, -pres_six, -pres_seven, -president) 


past = colnames(cleaned_past_presidents)


current_data = read_csv('italian_statements.csv') |> 
  mutate(executive = 'Giorgia Meloni')


all_data |>
  filter(!is.na(files))


all_data = bind_rows(current_data, cleaned_past_presidents) |>
  mutate(title = coalesce())


write_csv(all_data, "all_italian_statements.csv")


raw_dat = read_csv('all_italian_statements.csv')  


check = raw_dat |>
  filter(is.na(title) & is.na(subject)) |>
  distinct(url) |>
  pull(url)



## the old ones are going to be pretty tough to get a subject for 
## it looks like the main thing is that these aren't actually links
## with content 

fix_titles = raw_dat |>
mutate(title = ifelse(url == check[1],'Terrorismo: nota di Palazzo Chigi', title))

## so after some fiddiling it looks like these are really just the hrefs that point to links that we acutally used to scrape
get_rid = fix_titles |>
  filter(is.na(title) & is.na(subject)) |>
  pull('url')

clean_up = fix_titles |>
  filter(!url %in% get_rid)


write_csv(clean_up, 'all_italian_statements.csv')


raw_dat = read_csv('all_italian_statements.csv')




