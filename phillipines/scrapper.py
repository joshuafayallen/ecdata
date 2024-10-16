%pip install selenium
%pip install requests
%pip install lxml 
%pip install polars


import random 
import time 
from selenium.webdriver.common.by import  By
import requests 
from lxml import html
from seleniumbase import Driver
import polars as pl 
import string
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, WebDriverException
from selenium.common.exceptions import NoSuchElementException

base_url = 'https://pco.gov.ph/presidential-speech/'



links = [base_url + "page/" + str(i) for i in range(2,45)] 

links.append(base_url)


driver = Driver(uc = True)

driver.maximize_window()


def get_links(driver):
    links_this_page = list()
    get_refs = driver.find_elements(By.CSS_SELECTOR, ".clamp-4")
    get_all_refs = [get_refs.get_attribute("href") for get_refs in get_refs]
    links_this_page.append(get_all_refs)
    return links_this_page


def get_dates(driver):
    dates_this_page = list()
    get_dates = driver.find_elements(By.CSS_SELECTOR, ".release-date")
    get_all_dates = [get_dates.get_attribute("textContent") for get_dates in get_dates]
    dates_this_page.append(get_all_dates)
    return dates_this_page   

dates_list_to_add = []

links_list_to_add = []

for i in links:
    driver = Driver(uc = True)
    driver.maximize_window()
    driver.get(i)
    try: 
        find_recapta = driver.find_element(By.XPATH, '/html/body/div/div/div[1]/div')
        find_recapta.click
        time.sleep(25)
    except NoSuchElementException:
        pass
    time.sleep(30)
    dates_scraped = get_dates(driver)
    time.sleep(10)
    links_scraped = get_links(driver)
    dates_list_to_add.append(dates_scraped)
    links_list_to_add.append(links_scraped)
    driver.quit()



bind_scraped_data = pl.DataFrame([dates_list_to_add, links_list_to_add], schema = ["dates", "links"]).explode(["dates", "links"])

unnested_data  = bind_scraped_data.explode(["dates", "links"])


filtered_data = unnested_data.filter(pl.col("dates") != "null")


filtered_data.write_csv("links_to_scrape_phillipines.csv")


just_links = filtered_data["links"].to_list()


ef get_text(driver):
    text_this_page = list()
    get_text_el= driver.find_elements(By.CSS_SELECTOR, ".release-content p")
    get_all_texts = [get_text_el.get_attribute("textContent") for get_text_el in get_text_el]
    text_this_page.append(get_all_texts)
    return text_this_page

    import numpy as np

texts = []

for i in just_links:
    url_scraping = i
    driver = Driver(uc = True, headless=True)
    driver.get(i)
    time.sleep(25)
    texts_on_screen = get_text(driver)
    texts.append((texts_on_screen, url_scraping))
    driver.quit()



max_length = max(len(t) for t in texts)

## now lets pad the tuples 


texts_padded = [tuple(t) + (np.nan,) * (max_length - len(t)) for t in texts]




texts_pl = pl.DataFrame(texts_padded, schema=["texts", "urls"])


texts_pl.head()


expand_pl = texts_pl.explode(["texts"]).explode(["texts"])


expand_pl.head()


expand_pl.write_csv("phillipines_statements.csv")