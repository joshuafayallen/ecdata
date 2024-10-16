%pip install selenium
%pip install polars
%pip install beautifulsoup4
%pip install requests
%pip install pyahk

## I think the issue is less that they are actively doing something annoying 
## to ensure nobody is scraping or that it is prett
## it is just like a bad website that is slow 

import polars as pl
import time 
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import  By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, WebDriverException
from urllib.request import urlopen
from bs4 import BeautifulSoup
import re 


links = pl.read_csv('links.csv')

driver = webdriver.Firefox()

driver.maximize_window()

links_vec = links['url']

driver.get(links_vec[0])

## cool this will work 
title = driver.find_elements(By.XPATH, '//*[@id="contenido"]/table[1]/tbody/tr/td[1]')

[title.get_attribute('textContent') for title in title]


date = driver.find_elements(By.XPATH, '//*[@id="contenido"]/table[1]/tbody/tr/td[2]')
[date.get_attribute('textContent') for date in date]



### we got your asss 

def get_subject(driver):
    subject = WebDriverWait(driver, 30).until(EC.presence_of_all_elements_located((By.XPATH, '//*[@id="contenido"]/table[1]/tbody/tr/td[1]')))
    subjects = [subject.get_attribute('textContent') for subject in subject]
    return subjects


get_subject(driver)


def get_date(driver):
    date = WebDriverWait(driver, 30).until(EC.presence_of_all_elements_located((By.XPATH, '//*[@id="contenido"]/table[1]/tbody/tr/td[2]')))
    dates = [date.get_attribute('textContent') for date in date]
    return dates



def get_links(driver):
    link = WebDriverWait(driver, 30).until(EC.presence_of_all_elements_located((By.XPATH, '//*[@id="contenido"]/table[1]/tbody/tr/td[3]/a')))
    links = [link.get_attribute('href') for link in link]
    return links

get_links(driver)

data = {
    'links' : [],
    'date' : [],
    'subject' : []
}

max_retries = 5
success = False

for link in links_vec:
    retries = 0  # Initialize retries for each link
    while retries < max_retries and not success:
        try:
            driver.get(link)
            links_page = get_links(driver)
            date_page = get_date(driver)
            subject_page = get_subject(driver)
            data['links'].append(links_page)
            data['date'].append(date_page)
            data['subject'].append(subject_page)

            success = True  # Set success to True if no exception occurs
            time.sleep(5)
        except Exception as e:
            retries += 1
            print(f"Retry {retries}/{max_retries} for link {link} due to error: {e}")
            time.sleep(2)  # Wait before retrying
    if not success:
        print(f"Failed to scrape {link} after {max_retries} retries.")
    else:
        print('Done scraping', link)
        df = pl.DataFrame(data)
        df.write_parquet('statement_links.parquet')
    success = False  # Reset success for the next link


links_scrape = pl.DataFrame(data)   

links_scrape.head()

## it looks like append was being a real dick 

cleaned_data = links_scrape.explode(['links', 'date', 'subject'])

cleaned_data.head()


cleaned_data.write_parquet('statement_links.parquet')

links_data = pl.read_parquet('statement_links.parquet')


link = links_data['links'][0]

htmls = urlopen(link).read()


soup = BeautifulSoup(htmls, features='html.parser')

for script in soup(['script', 'style']):
    script.extract()

soup = soup.find(class_ = 'post_Noti_Princ')

text = soup.get_text(separator='\n', strip=True)

text_data = pl.DataFrame(data = {'link' : link}).with_columns(text = pl.lit(text)).with_columns(text = pl.col('text').str.split(by = '\n')).explode('text')



text_data.write_csv('check.csv')

def read_urls_safe(link, retries = 5):
    for attempt in range(retries):
        try:
            htmls = urlopen(link).read()
            time.sleep(5)
            return htmls
        except Exception as e:
            if attempt < retries - 1:
                time.sleep(5)
            else: 
                raise e


text_data = pl.DataFrame()


links_vec = links_data['links']


for link in links_vec:
    try:
        htmls = read_urls_safe(link)
        soup = BeautifulSoup(htmls, features='html.parser')
        for script in soup(['script', 'style']):
            script.extract()
        soup = soup.find(class_='post_Noti_Princ')
        text = soup.get_text(separator='\n', strip = True)
        temp_df = pl.DataFrame(data = {'link': link}).with_columns(text = pl.lit(text).str.split(by = '\n')).explode('text')
        text_data = text_data.vstack(temp_df)
        text_data.write_parquet('venzuelan_statements.parquet')
        print('done scraping', link)
    except Exception as e:
        print(f'Failed to process {link}: e')


## currently on 24206
## it looks like it got super hung on one of the links 





data_scraped.head()

alread_scraped = data_scraped['link']

scrape_these = links_data.filter(pl.col('links').is_in(alread_scraped).not_())

links_vec = scrape_these['links']

data_two = pl.DataFrame()

for link in links_vec:
    try:
        htmls = read_urls_safe(link)
        soup = BeautifulSoup(htmls, features='html.parser')
        for script in soup(['script', 'style']):
            script.extract()
        soup = soup.find(class_='post_Noti_Princ')
        text = soup.get_text(separator='\n', strip = True)
        temp_df = pl.DataFrame(data = {'link': link}).with_columns(text = pl.lit(text).str.split(by = '\n')).explode('text')
        text_data = data_two.vstack(temp_df)
        text_data.write_parquet('venzuelan_statements.parquet')
        print('done scraping', link)
    except Exception as e:
        print(f'Failed to process {link}: e')



