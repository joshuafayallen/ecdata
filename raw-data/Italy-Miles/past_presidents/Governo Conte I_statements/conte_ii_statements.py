pip install polars 
pip install selenium



import polars as pl 
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium import webdriver
import time 


links_dat = pl.read_csv('links.csv')

links_raw = links_dat['urls']

driver = webdriver.Firefox()


def get_date(driver, timeout=10):
    WebDriverWait(driver, timeout).until(
        EC.visibility_of_element_located((By.CSS_SELECTOR, '.h5'))
    )
    date_page = driver.find_element(By.CSS_SELECTOR, '.h5')
    date = date_page.get_attribute('textContent')
    return date

def get_subject(driver, timeout=10):
    WebDriverWait(driver, timeout).until(
        EC.visibility_of_element_located((By.CLASS_NAME, 'title_large'))
    )
    subject_page = driver.find_element(By.CLASS_NAME, 'title_large')
    subject = subject_page.get_attribute('textContent')
    return subject 

def get_text(driver, timeout=10):
    WebDriverWait(driver, timeout).until(
        EC.visibility_of_all_elements_located((By.CSS_SELECTOR, '.field-item > p'))
    )
    text_pages = driver.find_elements(By.CSS_SELECTOR, '.field-item > p')
    text = [text_page.get_attribute('textContent') for text_page in text_pages]
    return text


driver = webdriver.Firefox()
failed_urls = []
max_retries = 2

data = {
    "date":  [],
    "subject": [],
    "text" : [],
    "url" : []

}




for link in links_raw:
    attempt = 0
    success = False
    while attempt < max_retries and not success:
        try:
            time.sleep(5)
            driver.get(link)
            text_page = get_text(driver)
            subject_page = get_subject(driver)
            date_page = get_date(driver)

            for paragraph in text_page:
                data['date'].append(date_page)
                data['subject'].append(subject_page)
                data['text'].append(paragraph)
                data['url'].append(link)
                
            print("Done Scraping", link)
            success = True
        except Exception as e:
            attempt += 1
            if attempt < max_retries:
                print(f"Retry {attempt} for {link} due to exception: {e}")
                time.sleep(5)
            else:
                print(f"Failed to scrape {link} after {max_retries} attempts. Exception: {e}")
                failed_urls.append(link)

driver.quit()


conte_ii_data = pl.DataFrame(data)


conte_ii_data.head()

italian_to_english_months = {
    "Gennaio": "January",
    "Febbraio": "February",
    "Marzo": "March",
    "Aprile": "April",
    "Maggio": "May",
    "Giugno": "June",
    "Luglio": "July",
    "Agosto": "August",
    "Settembre": "September",
    "Ottobre": "October",
    "Novembre": "November",
    "Dicembre": "December"
}

def replace_italian_months(date_str):
    for it_month, en_month in italian_to_english_months.items():
        date_str = date_str.replace(it_month, en_month)
    return date_str 


parsed_dates = conte_ii_data.with_columns(date = pl.col('date').map_elements(lambda x: replace_italian_months(x)))


import os 

if not os.path.exists('data'):
    os.makedirs('data')


parsed_dates.write_csv("data/conte_ii_statements.csv")



## throwing this over to R in order to use lubridate
