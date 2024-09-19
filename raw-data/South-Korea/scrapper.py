%pip install random
%pip install requests
%pip install selenium
%pip install polars


import random 
import time 
from selenium.webdriver.common.by import  By
import requests 
from lxml import html
from selenium import webdriver
import polars as pl 
import string
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, WebDriverException
from selenium.common.exceptions import NoSuchElementException



base_url = 'https://www.president.go.kr/president/speeches'

driver = webdriver.Firefox()

driver.maximize_window()

driver.get(base_url)


def extract_url_part(url):
    start_index = url.find("'/president/speeches/") + len("'/president/speeches/")
    end_index = url.find("'", start_index)
    return url[start_index:end_index]

def url_scrapper(driver):
    refs = driver.find_elements(By.CSS_SELECTOR, '.infoArea a')
    all_refs = [refs.get_attribute("href") for refs in refs]
    return all_refs



todays_date = '2023.10.27'

refs = []

find_date = driver.find_element(By.CSS_SELECTOR, ".noticeInfo")
dates_on_page = find_date.get_attribute("textContent")

def move_page(page_number):
    button = WebDriverWait(driver, 25).until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[2]/div/article/div/div[2]/ul/li[' + str(page_number) + ']/button')))
    button.click()


def is_next_available():
    try:
        next_button = driver.find_element(By.XPATH, '/html/body/div[2]/div/article/div/div[2]/button[3]')
        return next_button.is_displayed() and "javascript:void(0)" not in next_button.get_attribute("onclick")
    except:
        return False



links = []
i = 1
while True:
    try:
        refs_page = url_scrapper(driver)
        links.extend(refs_page)
        move_page(i)

        if i == 5:  
            next_button = WebDriverWait(driver, 10).until(
                EC.element_to_be_clickable((By.CSS_SELECTOR, '.next')))
            next_button.click()
            i = 1
        else: 
            i += 1
        time.sleep(5)
    except TimeoutException:
        break
     
print(links)



links_df = pl.DataFrame(links, schema=["links_scraped"])


links_df.write_csv("scraped_links_df.csv")

driver.quit()