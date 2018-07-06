require '../../Training/RUBY/lib/2_2_merge_sort/merge_sort.rb'
require 'csv'

def restructure_data
  # Read entire csv
  matches = CSV.read('../data/match_data_downloaded/atp_matches_1993.csv', headers: true)
  
  # Sort by descending date
  merge_sort!(matches) { |match| -match['tourney_date'].to_i }

  # Set of tourney rounds from last to first one
  rounds = ['F', 'SF', 'QF', '16R', '32R', '64R', '128R', '256R']

  # Sort matches by rounds within the tourneys
  sorted_matches = sort_by_attr_set!(matches, rounds)

=begin
  matches.each do |match|
    puts match.inspect
  end
=end

end

private

# Sort matches by attributes set as a criteria
def sort_by_attr_set!(matches, attr_set)
#  puts matches.headers
#  puts

  # Sorted matches to return
  sorted_matches = Array.new(matches.size, [])

  # Headers for a new file
  headers = matches.headers[0..30]

  # per = period (e.g. last 2 weeks),, df = double faults,
  # 1st_in = first serve in, %w_1st = % of first serve won,
  # %w_2nd = % of second serve won.
  add_headers = ["1/rank_diff", "1/rank_p_diff",
		 "1/age_diff", "1/hgt_diff",
		 "1/aces_last_diff", "1/aces_per_avg_diff",
		 "1/aces_per_max_diff", "1/aces_per_min_diff",
		 "1/df_last_diff", "1/df_per_avg_diff",
		 "1/df_per_max_diff", "1/df_per_min_diff",
                 "1/1st_in_last_diff", "1/1st_in_per_avg_diff",
		 "1/1st_in_per_max_diff", "1/1st_in_per_min_diff",
		 "1/%w_1st_last_diff", "1/%w_1st_per_avg_diff",
		 "1/%w_1st_per_max_diff", "1/%w_1st_per_min_diff",
		 "1/%w_2nd_last_diff", "1/%w_2nd_per_avg_diff",
		 "1/%w_2nd_per_max_diff", "1/%w_2nd_per_min_diff"]

  add_headers.each do |new_header|
    headers << new_header
  end

  # Add headers to a new file 
  sorted_matches[0] = headers

  matches.each do |row|

    curr_date = row['tourney_date'].to_i
#    puts curr_date

  end

#  puts sorted_matches[0]
#  puts sorted_matches.size
#  puts sorted_matches.inspect
end

restructure_data
