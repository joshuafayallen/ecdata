

import polars as pl 
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium import webdriver
import time 


links_dat = pl.read_csv('links.csv')

links_raw = links_dat['links']

driver = webdriver.Firefox()

driver.get(links_raw[0])


def get_date(driver):
    date_page = driver.find_element(By.CSS_SELECTOR, '.h5')
    date = date_page.get_attribute('textContent')
    return date

def get_subject(driver):
    subject_page = driver.find_element(By.CLASS_NAME, "title_large")
    subject = subject_page.get_attribute('textContent')
    return subject 

def get_text(driver):
    text_page = driver.find_elements(By.CSS_SELECTOR, '.field-item > p')
    text = [text_page.get_attribute('textContent') for text_page in text_page]
    return text


data = {
    "date":  [],
    "subject": [],
    "text" : [],
    "url" : []

}



failed_urls = []

max_retries = 2

for links in links_raw:
    attempt = 0
    succes = False
    while attempt < max_retries and not succes:
        try: 
            time.sleep(5)
            driver.get(links)
            text_page = get_text(driver)
            subject_page = get_subject(driver)
            date_page = get_date(driver)
            for paragraph in text_page:
                data['date'].append(date_page)
                data['subject'].append(subject_page)
                data['text'].append(paragraph)
                data['url'].append(links)
                print("Done Scraping", links)
                succes = True
        except Exception as e:
            attempt += 1
            if attempt < max_retries:
                print(f"Retry {attempt} for {links} due to exception: {e}")
                time.sleep(5)
            else:
                print(f"Failed to scrape {links} after {max_retries} attempts. Exception: {e}")
                failed_urls.append(links)
                succes = False


links_list = links_raw.to_list()

conte_i_statements = pl.DataFrame(data)

conte_i_statements.head()


links_already_scraped = conte_i_statements.select(pl.col('url')).rename({'url': 'links'})


links_already_scraped.head()

links_need_to_scrape = links_dat.join(links_already_scraped, on = ['links'], how = 'anti')

links_scrape_vec = links_need_to_scrape['links']

# the functions are a bit quick so lets just rewrite them

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

data2 = {
    "date":  [],
    "subject": [],
    "text": [],
    "url": []
}

driver = webdriver.Firefox()
failed_urls2 = []
max_retries = 2

for link in links_scrape_vec:
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
                data2['date'].append(date_page)
                data2['subject'].append(subject_page)
                data2['text'].append(paragraph)
                data2['url'].append(link)
                
            print("Done Scraping", link)
            success = True
        except Exception as e:
            attempt += 1
            if attempt < max_retries:
                print(f"Retry {attempt} for {link} due to exception: {e}")
                time.sleep(5)
            else:
                print(f"Failed to scrape {link} after {max_retries} attempts. Exception: {e}")
                failed_urls2.append(link)

driver.quit()



date_two = pl.DataFrame(data2)


full_data = pl.concat([conte_i_statements, date_two], how = 'vertical')


full_data.head()

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

italian_statements = full_data.with_columns(date = pl.col('date').map_elements(replace_italian_months))

### oh we need to make these into lubridate dates 
italian_statements.write_csv("conte_i_statements.csv")


