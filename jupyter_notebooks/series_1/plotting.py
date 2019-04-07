import pandas as pd
import numpy as np
import os
import csv
from pandas.plotting import scatter_matrix
import matplotlib

# Pandas display options tweaking
pd.options.display.max_columns = None
INIT_MAX_ROWS = 50
pd.options.display.max_rows = INIT_MAX_ROWS

ROOT_DIR = os.path.abspath(os.path.join(os.getcwd(), '../../'))
print('Root directory:', ROOT_DIR)
# Downloaded files path
DOWNL_F_P = os.path.join(ROOT_DIR, 'match_data', 'match_data_downloaded')
# Preprocessed files path
PREP_F_P = os.path.join(ROOT_DIR, 'match_data', 'match_data_preprocessed')

preprocessed_data_file = 'atp_matches_1991-2018_preprocessed_final.csv'
preprocessed_data_full_path = os.path.join(PREP_F_P, preprocessed_data_file)
preprocessed_data = pd.read_csv(preprocessed_data_full_path, header=0, encoding='utf-8-sig', engine='python')

scatter_matrix(preprocessed_data, figsize=(200,200))