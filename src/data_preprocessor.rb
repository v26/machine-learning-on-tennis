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
end
