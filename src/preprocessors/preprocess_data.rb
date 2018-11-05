require_relative '../lib/data_preprocessor.rb'
require_relative '../lib/data_restruct.rb'

include DataPreprocessor
include DataRestruct

path = "../data/match_data_downloaded"
file_template = "atp_matches_"
files = get_filenames(file_template, 1993, 2018)
all_matches_file = "atp_matches_1993-2018.csv"

#unite_csv_files(all_matches_file, path, *files)
preprocess_data(all_matches_file)

#total_chunks = SmarterCSV.process(all_matches_file, {chunk_size: 1, remove_empty_values: false, remove_zero_values: false})

=begin
i = CSV.foreach(all_matches_file, headers: true)
puts ObjectSpace.memsize_of(i)
ic = i.clone
match = i.next
puts match.inspect
puts '1: ' + match['tourney_id'].to_s + "  " + match['match_num'].to_s
i.next
i.next
match1 = i.next
puts '1: ' + match1['tourney_id'].to_s + "  " + match1['match_num'].to_s

match2 = ic.next
puts '2: ' + match2['tourney_id'].to_s + "  " + match2['match_num'].to_s
=end
