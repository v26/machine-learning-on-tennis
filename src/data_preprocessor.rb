require 'objspace'
require_relative 'data_sort'
require 'smarter_csv'
require 'csv'
require 'date'

module DataPreprocessor

  # per = period (e.g. last 10 days), 
  # df = double faults,
  # 1st_in = first serve in,
  # %w_1st = % of first serve won,
  # %w_2nd = % of second serve won.
  @@res_headers = [
    "1/rank_diff",           "1/rank_p_diff",
    "1/age_diff",            "1/hgt_diff",
    "1/aces_last_diff",      "1/aces_per_avg_diff",
    "1/aces_per_max_diff",   "1/aces_per_min_diff",
    "1/df_last_diff",        "1/df_per_avg_diff",
    "1/df_per_max_diff",     "1/df_per_min_diff",
    "1/1st_in_last_diff",    "1/1st_in_per_avg_diff",
    "1/1st_in_per_max_diff", "1/1st_in_per_min_diff",
    "1/%w_1st_last_diff",    "1/%w_1st_per_avg_diff",
    "1/%w_1st_per_max_diff", "1/%w_1st_per_min_diff",
    "1/%w_2nd_last_diff",    "1/%w_2nd_per_avg_diff",
    "1/%w_2nd_per_max_diff", "1/%w_2nd_per_min_diff"
  ]

#  @@headers_for_processed = [
#    "rank",           "rank_points",
#    "age",            "ht",
#    "aces_last",      "aces_per_avg",
#    "aces_per_max",   "aces_per_min",
#    "df_last",        "df_per_avg",
#    "df_per_max",     "df_per_min",
#    "1st_in_last",    "1st_in_per_avg",
#    "1st_in_per_max", "1st_in_per_min",
#    "%w_1st_last",    "%w_1st_per_avg",
#    "%w_1st_per_max", "%w_1st_per_min",
#    "%w_2nd_last",    "%w_2nd_per_avg",
#    "%w_2nd_per_max", "%w_2nd_per_min"
#  ]

  @@headers_to_parse = [
    :winner_rank,        :loser_rank,
    :winner_rank_points, :loser_rank_points,
    :winner_age,         :loser_age,
    :winner_ht,          :loser_ht,
    :w_ace,              :l_ace,
    :w_df,               :l_df,
    :w_svpt,             :l_svpt,
    :w_1stin,            :l_1stin,
    :w_1stwon,           :l_1stwon,
    :w_2ndwon,           :l_2ndwon,
  ]

  def preprocess_data(file)
    path = '../data/match_data_downloaded'
    dest_path = 'preprocessed_data/'
    puts "reading file..."
    output_name = "preprocessed_atp_matches_1993-2018.csv"

=begin
    chunk_number = "8200 - 8600"
    headers_written = false
    sorted_matches = SmarterCSV.process(dest_path + dest_file, {remove_empty_values: false, remove_zero_values: false})
    chunk = sorted_matches[8200...8600]
    preprocess_matches(chunk, headers_written, chunk_number)
=end

    @@written_matches = 0
    chunk_number = 0
    headers_written = false

    total_chunks = SmarterCSV.process(file, {chunk_size: 1000, remove_empty_values: false, remove_zero_values: false})# do |chunk|
    start_chunk_n = 0
    end_chunk_n = 55
    end_chunk_n = end_chunk_n < total_chunks.size ?
                  end_chunk_n :
                  total_chunks.size

    chunk_number = start_chunk_n
    chunks_part = total_chunks[start_chunk_n...end_chunk_n]
    chunks_part.each do |chunk|
      puts "preprocessing chunk #{chunk_number}..."
      dest = dest_path + chunk_number.to_s + output_name
      preprocess_matches(dest, chunk, headers_written, chunk_number)
      chunk_number += 1
    end
  end

  private

  def preprocess_matches(dest, matches, headers_written, chunk_number)
    dest_path = "preprocessed_data/"
    # period for previous matches processing, days
    per = 14
    # number of previous matches to process
    num_min = 3
    num_max = 10

    c = 0
    matches.each_with_index do |match, index|
      c += 1
      puts "#{chunk_number}   #{c}   #{@@written_matches}"
      winner_matches = get_valid_matches(
        matches,
        index,
        per,
        num_min,
        num_max,
        :winner_name
      )
      next if winner_matches.nil?

      loser_matches = get_valid_matches(
        matches,
        index,
        per,
        num_min,
        num_max,
        :loser_name
      )
      next if loser_matches.nil?

      winner_processed = process_matches(winner_matches)
      loser_processed = process_matches(loser_matches)

      if index % 2 == 0 
        res = get_res(winner_processed, loser_processed, 1)
      else
        res = get_res(loser_processed, winner_processed, -1)
      end

      if !headers_written
        CSV.open(dest, 'w') do |csv|
          csv << res.keys
        end
        headers_written = true
      end

#puts res.inspect
      write_res(res, dest)
      @@written_matches += 1
#      break if c == 11
    end
  end

  def get_valid_matches(matches, index, per, num_min, num_max, player_name)
    match_data = []
    curr_match = matches[index]
    curr_date = get_date(curr_match[:tourney_date], '%Y%m%d')
    curr_name = curr_match[player_name]

    matches[(index + 1)...matches.size].each do |prev_match|
      catch :missing_value do
        prev_date = get_date(prev_match[:tourney_date], '%Y%m%d')

        valid_date = (curr_date - prev_date).to_i < per
        valid_count = match_data.size <= num_max
        valid_name = curr_name == prev_match[:winner_name] ||
                     curr_name == prev_match[:loser_name]

        if valid_date && valid_count
          if valid_name
            add_match = {}

            if curr_name == prev_match[:winner_name]
              headers = @@headers_to_parse.select.with_index { |_, i| i.even? }
            else
              headers = @@headers_to_parse.select.with_index { |_, i| i.odd? }
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
    match_data.size < num_min ? nil : match_data
  end

  def process_matches(matches)
#  @@headers_for_processed = [
#    "rank",            "rank_points",
#    "age",             "ht",
#    "aces_last",       "aces_per_avg",
#    "aces_per_max",    "aces_per_min",
#    "df_last",         "df_per_avg",
#    "df_per_max",      "df_per_min",
#    "perc_1st_in_last",    "perc_1st_in_per_avg",
#    "perc_1st_in_per_max", "perc_1st_in_per_min",
#    "perc_w_1st_last",     "perc_w_1st_per_avg",
#    "perc_w_1st_per_max",  "perc_w_1st_per_min",
#    "perc_w_2nd_last",    "perc_w_2nd_per_avg",
#    "perc_w_2nd_per_max", "perc_w_2nd_per_min"
#  ]

#  @@headers_to_parse = [
#    :winner_rank,        :loser_rank,
#    :winner_rank_points, :loser_rank_points,
#    :winner_age,         :loser_age,
#    :winner_ht,          :loser_ht,
#    :w_ace,              :l_ace,
#    :w_df,               :l_df,
#    :w_svpt,             :l_svpt,
#    :w_1stin,            :l_1stin,
#    :w_1stwon,           :l_1stwon,
#    :w_2ndwon,           :l_2ndwon,
#  ]

    res = {}

    prefix = ""

    headers_2_dup = [:rank, :rank_points, :age, :ht]
    headers_2_dup.each do |header|
      prefix = matches[0][:winner_rank].nil? ? "loser_" : "winner_"
      header_2_process = concat_sym(prefix, header)
      result = matches[0][header_2_process]
#      result = last(matches, header.to_s)
      if result.class.name == "Float"
        res[header] = result.round(3)
      else
        res[header] = result
      end
    end

    res[:aces_last] = last(matches, "ace")
    res[:aces_per_avg] = avg(matches, "ace")
    res[:aces_per_min] = min(matches, "ace")
    res[:aces_per_max] = max(matches, "ace")

    res[:df_last] = last(matches, "df")
    res[:df_per_avg] = avg(matches, "df")
    res[:df_per_min] = min(matches, "df")
    res[:df_per_max] = max(matches, "df")

    res[:perc_1st_in_last] = last(matches, "1stin", "svpt") { |a, b| perc(a, b) }
    res[:perc_1st_in_avg] = avg(matches, "1stin", "svpt") { |a, b| perc(a, b) }
    res[:perc_1st_in_min] = min(matches, "1stin", "svpt") { |a, b| perc(a, b) }
    res[:perc_1st_in_max] = max(matches, "1stin", "svpt") { |a, b| perc(a, b) }

    res[:perc_w_1st_last] = last(matches, "1stwon", "1stin") { |a, b| perc(a, b) }
    res[:perc_w_1st_avg] = avg(matches, "1stwon", "1stin") { |a, b| perc(a, b) }
    res[:perc_w_1st_min] = min(matches, "1stwon", "1stin") { |a, b| perc(a, b) }
    res[:perc_w_1st_max] = max(matches, "1stwon", "1stin") { |a, b| perc(a, b) }

    res[:perc_w_2nd_last] = last(matches, "2ndwon", "1stin", "svpt") { |a, b, c| perc(a, c - b)}
    res[:perc_w_2nd_avg] = avg(matches, "2ndwon", "1stin", "svpt") { |a, b, c| perc(a, c - b)}
    res[:perc_w_2nd_min] = min(matches, "2ndwon", "1stin", "svpt") { |a, b, c| perc(a, c - b)}
    res[:perc_w_2nd_max] = max(matches, "2ndwon", "1stin", "svpt") { |a, b, c| perc(a, c - b)}

    res
  end

  def concat_sym(prefix, appen)
    sym = (prefix.to_s + appen.to_s).to_sym
  end

  def perc(part, full)
    return 0 if full.to_f == 0
    perc = part.to_f * 100 / full.to_f
    perc.round(2)
  end

  def last(matches, *attribs)
#    get_var = block_given? ? lambda { |item| yield(item) } : lambda { |item| item }
    last_match = matches[0]
    full_attribs = attribs.map { |attr| attr = last_match.keys.find { |key| /[\w\d]*#{attr}/ =~ key.to_s }.to_sym }
    if block_given?
      args = []
      full_attribs.each { |attr| args << last_match[attr] }
      last = yield(*args)
#    last = get_var[symb]
    else
      last = last_match[full_attribs[0]]
    end
    last
  end

  def avg(matches, *attribs)
    avg = 0
    args = []
    sum = 0
    matches.each do |match|
      full_attribs = attribs.map { |attr| attr = match.keys.find { |key| /[\w\d]*#{attr}/ =~ key.to_s }.to_sym }
      args = full_attribs.map { |attr| match[attr]}
      if block_given?
        sum += yield(*args)
      else
        sum += args[0]
      end
    end
    avg = (sum / matches.size).round(2)
#      last = get_var[symb]
    avg
  end

  def min(matches, *attribs)
    args = []
    res = []
    matches.each do |match|
#puts "attribs:"
#puts attribs
#puts matches.inspect
      full_attribs = attribs.map { |attr| attr = match.keys.find { |key| /[\w\d]*#{attr}/ =~ key.to_s }.to_sym }
      args = full_attribs.map { |attr| match[attr]}
      if block_given?
        res << yield(*args)
      else
        res << args[0]
#puts "res"
#puts res.inspect
      end
    end
#puts "res2"
#puts res.inspect
    min = res.min.round(2)
    min
#puts "min = #{min}"
#puts
  end

  def max(matches, *attribs)
    args = []
    res = []
    matches.each do |match|
      full_attribs = attribs.map { |attr| attr = match.keys.find { |key| /[\w\d]*#{attr}/ =~ key.to_s }.to_sym }
      args = full_attribs.map { |attr| match[attr]}
      if block_given?
        res << yield(*args)
      else
        res << args[0]
      end
    end
    max = res.max.round(2)
    max
  end

  def get_res(p1_data, p2_data, res_flag)
    res = {}
    p1_data.keys.each do |key|
      key_str = "1/" + key.to_s + "_diff"
      res_key = key_str.to_sym
      p1_val = p1_data[key].to_i
      p2_val = p2_data[key].to_i
      diff = p1_val - p2_val
      
      res[res_key] = diff == 0 ? 0 : (1 / diff.to_f).round(4)
    end
    res[:res] = res_flag
    res
  end

  def write_res(res, file_name)
    CSV.open(file_name, 'a') do |csv|
      csv << res.values
    end
  end

  def print_data(data_set, size, *attributes)
    size = data_set.size if size > data_set.size
    puts data_set.inspect
    puts size
    puts attributes.inspect
    (0...size).each do |i|
      item = data_set[i]
      attrib = item.keys if attributes.empty?
      puts attrib.inspect
      attrib.each do |key|
        print "#{item[key]}  "
      end
    puts if size > 0
    end
  end

  def get_date(match, format)
    Date.strptime(match.to_s, format)
  end
end

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
