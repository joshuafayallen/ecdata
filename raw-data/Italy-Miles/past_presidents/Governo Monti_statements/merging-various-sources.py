import polars as pl 
import os 

og_link_data = pl.read_csv('links.csv').filter((pl.col('speaker').is_in(['Presidente CdM', 'Presidenza'])))

linked_pages = pl.read_csv('webpages_data/webpage_links.csv').filter((pl.col('scrape_this_url') != 'false'))


pdfs_data = pl.read_csv('webpages_data/pdf_links.csv')

pdfs_data_pruned = pdfs_data.select({'filename','og_url'})

pdfs_data.head()


monti_webpage_statements = pl.read_csv('data/raw_monti_data.csv')

monti_pdf_statements = pl.read_csv('data/raw_monti_pdf.csv')



cleaned_pdf_files = monti_pdf_statements.with_columns(filename = pl.col('file').map_elements(lambda x: os.path.basename(x))).select({'filename', 'text'}).select(pl.exclude('file')).with_columns(filename = pl.col('filename').str.replace(r"_page_\d+", ".pdf"))


cleaned_pdf_files.head()

monti_webpage_statements.head()

small_webpages = linked_pages.select({'og_url', 'scrape_this_url'}).rename({'scrape_this_url': 'url'})

cleaned_pdf_files.head()

small_webpages.head()

merged_webpage_statement_data = monti_webpage_statements.join(small_webpages, on = ['url'])

pdfs_pruned = cleaned_pdf_files.join(pdfs_data_pruned, on = ['filename'])

pdfs_pruned.head()

merged_webpage_statement_data.head()

merge_data_scraped_webs = og_link_data.join(merged_webpage_statement_data, left_on = ['url'], right_on= ['og_url']).select(pl.exclude('url_right'))

merge_pdf_data = og_link_data.join(pdfs_pruned, left_on = ['url'], right_on =['og_url']).select(pl.exclude('filename')).rename({'text':'pdf_text',
'date':'doc_date', "url": 'file'}).select(pl.exclude('speaker'))

merge_pdf_data.head()

all_data = pl.concat([merge_data_scraped_webs, merge_pdf_data], how = 'horizontal')


all_data.head()

all_data.write_csv('data/monti_statements.csv')


