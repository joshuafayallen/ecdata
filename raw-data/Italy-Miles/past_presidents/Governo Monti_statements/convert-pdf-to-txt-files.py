%pip install pdf2image

import polars as pl 
import pytesseract
import cv2
import re 
import numpy as np
import jiwer
import pdf2image
import matplotlib.pyplot as plt
import glob
import os

pdfs = glob.glob(r'raw_pdfs/*.pdf')

print(pdfs)

data_directory = 'raw_images'
page_number = 1

base_names = []

for files in pdfs:
    name_pdfs = os.path.basename(files)
    base_names.append(name_pdfs)

names_sans_extenstion = [re.sub('.pdf', '', base_names) for base_names in base_names]


for file, name in zip(pdfs, names_sans_extenstion):
    images = pdf2image.convert_from_path(file)
    for image in images:
        image.save(os.path.join(data_directory, f'{name}_page_{page_number}.png'), 'PNG')
        page_number += 1


raw_images = glob.glob(r'raw_images/*.png')


image = cv2.imread(raw_images[0])


data = {
    'file': [],
    'text': []
}


for image in raw_images:
    image_in = cv2.imread(image)
    name = re.sub('.png', '.pdf', image)
    text = pytesseract.image_to_string(image_in)
    data['file'].append(name)
    data['text'].append(text)



    
pdf_data = pl.DataFrame(data)




pdf_data.write_csv('data/raw_monti_pdf.csv')
