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
  # Sorted matches to return
  sorted_matches = Array.new(matches.size, Array.new)

  tourney_dates = matches.map { |match| match["tourney_date"] }.uniq
  puts tourney_dates.inspect

  tourney_ids = Array.new(tourney_dates.size)
#  puts tourney_dates_and_ids.inspect

#  (0...tourney_dates_and_ids.size).each do |i|
#    tourney_dates_and_ids[i] = Array.new << tourney_dates[i]
#  end

#  puts tourney_dates_and_ids.inspect
  tourney_date_ind = 0
  matches.each do |match|
    tourney_date_ind += 1 if match["tourney_date"] != tourney_dates[tourney_date_ind]
    date = tourney_dates[tourney_date_ind]
    tourney_ids[tourney_date_ind] = Array.new if tourney_ids[tourney_date_ind] == nil
    id = match["tourney_id"]
    tourney_ids[tourney_date_ind] << id if 
        tourney_ids[tourney_date_ind][0] == nil ||
        !tourney_ids[tourney_date_ind].include?(id)


  end
  puts tourney_ids.inspect
  puts tourney_ids.size

  puts
  puts tourney_dates.size

#  puts sorted_matches.size
#  puts sorted_matches.inspect
end

restructure_data
