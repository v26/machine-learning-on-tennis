require 'csv'

matches = CSV.read('../data/match_data_downloaded/atp_matches_1993.csv', headers:true)

(matches.size - 1).downto(1).each do |match_index|
#  match_cp = matches[match_index].map { |e| e.dup }

  curr_match = matches[match_index]
  
  (match_index - 1).downto(1).each do |prev_match_index|
    prev_match = matches[prev_match_index]
    
    
    
  end  
end

def process_match(player_id_col, curr_match_ind, matches)
  oppo_col = player_id_col == 'winner_id' ? 'loser_id' : 'winner_id'

  match_index.downto(1).each do |prev_match_index| 
    prev_match = matches[prev_match_index]

    next if prev_match[player_id_col] != curr_match[player_id_col]
       || curr_match[oppo_col] != curr_match[player_id_col]

  end

  # Headers for a new file
  headers = matches.headers[0..30]
  
  # per = period (e.g. last 2 weeks),, df = double 
  # faults, 1st_in = first serve in, %w_1st = % of 
  # first serve won, %w_2nd = % of second serve won.
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


end
