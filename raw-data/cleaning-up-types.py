import polars as pl
import polars.selectors as cs
import re

raw_exec_data = pl.read_parquet('handofftopolars/exec_small.parquet')

make_paragraphs = raw_exec_data.with_columns(
    (pl.col('text').str.split(by = '\r\r\n\r\r\n').alias('text'))).explode('text').select(pl.exclude('saving_name')).with_columns(chars = pl.col('text').str.len_chars())


subset = make_paragraphs.filter((pl.col('chars') > 3)).select(pl.exclude('chars'))


subset.write_parquet('executive_statement_data/full_executive_statement_data_v2.parquet')


make_paragraphs.glimpse()
