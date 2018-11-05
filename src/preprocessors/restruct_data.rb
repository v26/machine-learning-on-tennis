require_relative 'data_restruct'

include DataRestruct

path = "../data/match_data_downloaded"
file_template = "atp_matches_"

path2 = "preprocessed_data/"
file_template2 = "preprocessed_atp_matches_1993-2018"

files = get_filenames(file_template, 1993, 2018)
#unite_csv_files("atp_matches_1993-2018.csv", path, *files)

files2 = get_preprocessed_filenames(file_template2, 0, 83)
puts files2.inspect
unite_preprocessed("preprocessed_atp_matches_1993-2018.csv", path2, *files2)
