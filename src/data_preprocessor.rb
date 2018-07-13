require_relative 'data_sort'
require 'smarter_csv'
require 'date'

def preprocess_data
  path = '../data/match_data_downloaded'
  file = 'atp_matches_2017.csv'

  matches = sort_matches(path, file)
#  print_m(matches)
#  check_rounds(matches)
  
  preprocess_matches_2(matches)
end

private

=begin
  # per = period (e.g. last 10 days), 
  # df = double faults,
  # 1st_in = first serve in,
  # %w_1st = % of first serve won,
  # %w_2nd = % of second serve won.
  res_headers = ["1/rank_diff", "1/rank_p_diff", 
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
		 "1/%w_2nd_per_max_diff", "1/%w_2nd_per_min_diff" ]

=end

def preprocess_matches_2(matches)
  res = []
  # period for previous matches processing, days
  per = 14
  # number of previous matches to process
  num = 10

  c = 0
  matches.each_with_index do |match, index|
    winner_matches = get_valid_matches(matches, index, per, num, :winner_name)
    next if winner_matches.nil?
    loser_matches = get_valid_matches(matches, index, per, num, :loser_name)
    next if loser_matches.nil?


#    winner_processed = process_matches(winner_matches)
#    loser_processed = process_matches(loser_matches)
#    if index % 2 == 0 
#      res = get_res(winner_processed, loser_processed, 1)
#    else
#      res = get_res(loser_processed, winner_processed, -1)
#    end

#    write_res(res)
  c += 1
  break if c == 30
  end
end

def get_valid_matches(matches, index, per, num, player_name)
  match_data = []
  curr_match = matches[index]
  curr_date = Date.strptime(curr_match[:tourney_date].to_s, '%Y%m%d')
  curr_name = curr_match[player_name]

  headers_to_process = [ :winner_rank, :loser_rank,
			 :winner_rank_points, :loser_rank_points,
			 :winner_age, :loser_age,
			 :winner_ht, :loser_ht,
			 :w_ace, :l_ace,
			 :w_df, :l_df,
			 :w_svpt, :l_svpt,
			 :w_1stin, :l_1stin,
			 :w_1stwon, :l_1stwon,
			 :w_2ndwon, :l_2ndwon, ]

  matches[(index + 1)...matches.size].each do |prev_match|
    catch :missing_value do
    prev_date = Date.strptime(prev_match[:tourney_date].to_s, '%Y%m%d')

    valid_date = (curr_date - prev_date).to_i < per
    valid_count = match_data.size < num
    valid_name = curr_name == prev_match[:winner_name] ||
                 curr_name == prev_match[:loser_name]

    if valid_date && valid_count
      if valid_name
        add_match = {}

        if curr_name == prev_match[:winner_name]
          headers = headers_to_process.select.with_index { |_, i| i.even? }
        else
          headers = headers_to_process.select.with_index { |_, i| i.odd? }
        end

        headers.each do |header|
          throw :missing_value and return nil if prev_match[header].nil?

          add_match[header] = prev_match[header]
        end
        match_data << add_match
      end
    else
      break
    end
    end
  end
#  print_data(match_data, 20, *headers_to_process)
end

def print_data(data_set, size = data_set.size, *attributes)
  size = data_set.size if size > data_set.size
  (0...size).each do |i|
    item = data_set[i]
    attributes.each do |key|
      print "#{item[key]}  "
    end
  end
  puts
end

preprocess_data
