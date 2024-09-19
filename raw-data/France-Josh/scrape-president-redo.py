import polars as pl
import random
import time
from selenium.webdriver.common.by import  By
import requests 
from selenium.webdriver.support.ui import WebDriverWait
from lxml import html
from selenium import webdriver
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, WebDriverException


def get_links(driver):
    get_refs = driver.find_elements(By.CSS_SELECTOR, '.newsBlock-title a')
    get_all_refs = [get_refs.get_attribute('href') for get_refs in get_refs]
    return get_all_refs

def get_subject(driver):
    subject = driver.find_elements(By.CSS_SELECTOR, '.newsBlock-title a')
    subject_page = [subject.get_attribute('textContent')  for subject in subject]
    return subject_page
#actualities > div.actualities-section > newsBlock-cat
def get_category(driver):
    cat = driver.find_elements(By.CSS_SELECTOR, '.newsBlock-cat') 
    all_cats = [cat.get_attribute('textContent') for cat in cat] 
    return all_cats   

def click_next_page(driver):
    next_page = driver.find_element(By.XPATH, "/*[contains(text(), 'successiva')]")
    next_page.click()
    time.sleep(5)
    return driver

def get_dates(driver):
    get_dates = driver.find_elements(By.CSS_SELECTOR, '.newsBlock-date')
    get_all_dates = [get_dates.get_attribute('textContent') for get_dates in get_dates]
    return get_all_dates


global_url = 'https://www.elysee.fr/toutes-les-actualites'

driver = webdriver.Chrome()


driver.get(global_url)

driver.maximize_window()





accept_cookies = driver.find_element(By.ID, "tarteaucitronPersonalize2")

accept_cookies.click()

all_articles = driver.find_element(By.ID, 'all-articles-link')

all_articles.click()

get_category(driver)

data = {
    'subject' : [],
    'date' : [],
    'link': [],
    'cat' : []
}



go_to_first_page = driver.find_element(By.CSS_SELECTOR, '.custom-pagination-first--page')

go_to_first_page.click()



is_disabled = False

try:
    while not is_disabled:
        try:

            links_on_page = get_links(driver)
            dates_on_page = get_dates(driver)
            subject_on_page = get_subject(driver)
            cat_on_page = get_category(driver)

            data['subject'].append(subject_on_page)
            data['date'].append(dates_on_page)
            data['link'].append(links_on_page)
            data['cat'].append(cat_on_page)

            next_button = WebDriverWait(driver, 10).until(
                EC.element_to_be_clickable((By.XPATH, "//*[contains(text(), 'Suivant')]"))
            )

            is_disabled = "disabled" in next_button.get_attribute("class")
            print("Next page button is", is_disabled, "Moving to next Page")
            
            if is_disabled:
                print("Reached Last Page")
                break
            
            next_button.click()
            time.sleep(15) 

        except Exception as e:
            print("An error occurred:", str(e))
            break
finally:
    print('Done')



french_links_data = pl.DataFrame(data)

french_links_data.head()


french_links_data.explode(['date', 'subject', 'link', 'cat'])
french_links_data.head()


french_links_data.write_parquet('rescraped_links.parquet')

driver.quit()


rescraping_links = pl.read_csv('rescrape_selenium.csv')


driver  = webdriver.Chrome()

driver.get(rescraping_links['link'][1])


accept_cookies = driver.find_element(By.ID, "tarteaucitronPersonalize2")

accept_cookies.click()


driver.maximize_window()

get_text = driver.find_elements(By.CSS_SELECTOR, '#main .container p')

[get_text.get_attribute('textContent') for get_text in get_text]

## 
check_links = driver.find_element(By.CSS_SELECTOR, '#main .cta-module__link a')