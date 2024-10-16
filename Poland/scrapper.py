%pip install polars 
%pip install selenium
%pip install time 
%pip install numpy
%pip install python-dateutil
%pip install pandas pyarrow


import polars as pl 
from selenium.webdriver.common.by import  By
from selenium
from seleniumbase import Driver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, WebDriverException
import numpy as np
from dateutil import parser



pols_data = pl.read_csv("poland_links.csv")


links_vec = pols_data['links']

driver = Driver(uc = True)

def get_links(driver, delay = 5):
    links_page = WebDriverWait(driver, delay).until(EC.presence_of_all_elements_located((By.CSS_SELECTOR, 'div.articles-item__title > h2 > a')))
    all_links = [links_page.get_attribute('href') for links_page in links_page]
    return all_links

refs = []

driver = Driver(uc = True, headless = True)


for links in links_vec:
    driver.get(links)
    links_on_page = get_links(driver, delay = 10)
    refs.extend(links_on_page)
    print("Done Scraping", links)


statement_links  = pl.DataFrame(refs, schema = ['links'])


statement_links.write_csv("statement_links.csv")


def get_text(driver, delay):
    text = WebDriverWait(driver, delay).until(EC.presence_of_all_elements_located((By.CSS_SELECTOR, '.articles-single__description > p')))
    all_text = [text.get_attribute('textContent') for text in text]
    return all_text


def get_subject(driver):
    subject = driver.find_element(By.CLASS_NAME, "page-title")
    subject_text = subject.get_attribute('textContent')
    return subject_text


def get_date(driver):
    date = driver.find_element(By.CLASS_NAME, 'articles-single__date')
    date_text = date.get_attribute('textContent')
    return date_text



full_data_vec = statement_links['links']


for i in full_data_vec:
    driver.get(i)
    text_page = get_text(driver, delay = 5 )
    date_page = get_date(driver)
    subject_page = get_subject(driver)
    for paragraph in text_page:
        data["date"].append(date_page)
        data["subject"].append(subject_page)
        data['text'].append(paragraph)
        data['url'].append(i)
    print("Done Scraping", i)


    statement_data = pl.DataFrame(data)

statement_data = statement_data.rename({"url": "links"})

scrape_these = statement_data.join(statement_links, on = 'links',
how = 'anti')


def get_text(driver, delay):
    text = WebDriverWait(driver, delay).until(EC.presence_of_all_elements_located((By.CSS_SELECTOR, '#main-content > div > div.row > div:nth-child(1) > div > div > div.articles-single__description')))
    all_text = [text.get_attribute('textContent') for text in text]
    return all_text


def get_subject(driver):
    subject = driver.find_element(By.CLASS_NAME, "page-title")
    subject_text = subject.get_attribute('textContent')
    return subject_text


def get_date(driver):
    date = driver.find_element(By.CLASS_NAME, 'articles-single__date')
    date_text = date.get_attribute('textContent')
    return date_text


second_vec = scrape_these['links']

failed_urls = []

max_retries = 2


for i in second_vec:
    attempt = 0
    success = False
    while attempt < max_retries and not success:
        try:
            driver.get(i)
            text_page = get_text(driver, delay=5)
            date_page = get_date(driver)
            subject_page = get_subject(driver)
            for paragraph in text_page:
                data["date"].append(date_page)
                data["subject"].append(subject_page)
                data['text'].append(paragraph)
                data['url'].append(i)
            print("Done Scraping", i)
            success = True  
        except Exception as e:
            attempt += 1
            if attempt < max_retries:
                print(f"Retry {attempt} for {i} due to exception: {e}")
                time.sleep(5)  
            else:
                print(f"Failed to scrape {i} after {max_retries} attempts. Exception: {e}")
                failed_urls.append(i)
                success = False



full_data = pl.DataFrame(data)

full_data.write_csv("poland_pres_statements.csv")


data_one = {
    "date": [],
    "subject": [],
    "text": [],
    "url": []
}


for i in full_data_vec:
    driver.get(i)
    text_page = get_text(driver, delay = 5 )
    date_page = get_date(driver)
    subject_page = get_subject(driver)
    for paragraph in text_page:
        data_one["date"].append(date_page)
        data_one["subject"].append(subject_page)
        data_one['text'].append(paragraph)
        data_one['url'].append(i)
    print("Done Scraping", i)


month_mapping = {
    'stycznia': 'January',
    'lutego': 'February',
    'marca': 'March',
    'kwietnia': 'April',
    'maja': 'May',
    'czerwca': 'June',
    'lipca': 'July',
    'sierpnia': 'August',
    'września': 'September',
    'października': 'October',
    'listopada': 'November',
    'grudnia': 'December'
}


def replace_polish_months(date_str):
    for pl_month, en_month in month_mapping.items():
        date_str = date_str.replace(pl_month, en_month)
    return date_str 


polish_statements = pl.DataFrame(data_one)


olish_statements.write_csv("poland_pres_statements.csv")


polish_statements_fix_dates = polish_statements.with_columns(date = pl.col('date').apply(replace_polish_months))


fixed_states = polish_statements_fix_dates.with_columns(date = pl.col('date').apply(lambda x : parser.parse(x, ignoretz = True)))


fixed_states.write_csv('poland_pres_statements.csv')

driver.quit()