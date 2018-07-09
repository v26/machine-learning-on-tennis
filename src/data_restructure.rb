require 'smarter_csv'

def restructure_data(path, file)
#  path = "../data/match_data_downloaded"
#  file = "atp_matches_1993.csv"
  dir_sep = "/"

  # read entire csv
  matches = SmarterCSV.process("#{path}#{dir_sep}#{file}")

  sort_matches!(matches)

#  print_m(matches)

#  check_rounds(matches)
  matches
end

private

def sort_matches!(matches)
  # set of tourney rounds from final to first ones
  rounds = ["F", "SF", "QF", "R16", "R32", "R64", "R128", "RR"]

  # sort data by tourney date, id, round
  # from latest to oldest one
  matches.sort_by! { |match| [-(match[:tourney_date].to_i), match[:tourney_id], rounds.index(match[:round].to_s)] }
end

def print_m(matches)
  id = :tourney_id
  date = :tourney_date

  matches.each { |match| puts "#{match[id]}  #{match[date]}  #{match[:round]}" }
end

def check_rounds(matches)
  puts
  uniq_rounds = matches.uniq { |match| match[:round] }
  print_m(uniq_rounds)
end

#restructure_data
