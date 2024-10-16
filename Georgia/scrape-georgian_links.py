%pip install selenium
%pip install polars

import polars as pl
from selenium import webdriver
from selenium.webdriver.common.by import By
import time


links_dat  = pl.read_csv('georgia_links_georgian.csv')


driver = webdriver.Firefox()



def get_links(driver):
    find_links = driver.find_elements(By.CSS_SELECTOR, '#news-data section > h2 > a')
    all_links = [find_links.get_attribute('href') for find_links in find_links]
    return all_links

def get_subject(driver):
    find_subject = driver.find_elements(By.CSS_SELECTOR, '#news-data section > h2 > a')
    all_subjects = [find_subject.get_attribute('textContent') for find_subject in find_subject]
    return all_subjects

find_dates = driver.find_elements(By.CSS_SELECTOR, '#news-data article > section > time')

check2  = [find_dates.get_attribute('textContent') for find_dates in find_dates]

def get_date(driver):
    find_dates = driver.find_elements(By.CSS_SELECTOR, '#news-data article > section > time')
    get_dates = [find_dates.get_attribute('textContent') for find_dates in find_dates]
    return get_dates

get_links(driver)


links = []
dates = []
subject = []

links_vec = links_dat['urls']


for link in links_vec:
    driver.get(link)
    time.sleep(5)
    links_page = get_links(driver)
    date_page = get_date(driver)
    subject_page = get_subject(driver)
    links.append(links_page)
    dates.append(date_page)
    subject.append(subject_page)
    print(f'Done Scraping {link}')


scraped_links_data = pl.DataFrame([links, dates, subject], schema=['links', 'dates', 'subject'])

expand_links = scraped_links_data.explode(['links', 'dates', 'subject'])


expand_links.write_csv('georgia_links_georgian.csv')

driver.quit()
