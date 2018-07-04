require '../../Training/RUBY/lib/2_2_merge_sort/merge_sort.rb'
require 'csv'

def restructure_data
  matches = CSV.read('../data/match_data_downloaded/atp_matches_1993.csv', headers: true)

  merge_sort!(matches) { |match| -match['tourney_date'].to_i }

  rounds = ['F', 'SF', 'QF', '16R', '32R', '64R', '128R', '256R']

  sort_by_attr_set!(matches, rounds)

=begin
  matches.each do |match|
    puts match.inspect
  end
=end

end

private

def sort_by_attr_set!(data, attr_set)

  data.each do |row|

    curr_date = row['tourney_date'].to_i
    puts curr_date

  end
end

restructure_data
