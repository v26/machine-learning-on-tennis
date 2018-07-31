require 'smarter_csv'
require 'csv'

module DataRestruct
  def sort_matches(path, file)
    dir_sep = "/"

    # read entire csv
    matches = SmarterCSV.process("#{path}#{dir_sep}#{file}", remove_empty_values: false, remove_zero_values: false)
    matches.map do |match|
      match.keys.each { |key| match[key] = nil if match[key] == "" }
    end
    sort_matches_hlpr!(matches)
    matches
  end

  def unite_csv_files(res_file_name, path, *files)
    headers = CSV.open(path + "/" + files[0], 'r') { |csv| csv.first }
    CSV.open(res_file_name, "w") { |csv| csv << headers }

    files.each do |file|
      sorted_matches = sort_matches(path, file)

      CSV.open(res_file_name, "a") do |csv|
        sorted_matches.each do |match|
          csv << match.values
        end
      end
    end
  end

  def unite_preprocessed(res_file_name, path, *files)
    headers = CSV.open(path + files[0], 'r') { |csv| csv.first }
    CSV.open(res_file_name, "w") { |csv| csv << headers }

    files.each do |file|
      # read entire csv
puts "reading #{file}..." 
      matches = SmarterCSV.process("#{path}#{file}", remove_empty_values: false, remove_zero_values: false)
      matches.map do |match|
        match.keys.each { |key| match[key] = nil if match[key] == "" }
      end
#puts matches.inspect
#break
      CSV.open(res_file_name, "a") do |csv|
        matches.each do |match|
          csv << match.values
        end
      end
    end
  end

  def get_filenames(file_template, first_year, last_year)
    files = []
    last_year.downto(first_year).each do |year|
      files << "#{file_template}#{year}.csv"
    end
    files
  end

  def get_preprocessed_filenames(file_template, first_num, last_num)
    files = []
    (first_num..last_num).each do |num|
      files << "#{num}#{file_template}.csv"
    end
    files
  end

  private

  def sort_matches_hlpr!(matches)
    # set of tourney rounds from final to first ones
    rounds = ["F", "SF", "QF", "R16", "R32", "R64", "R128", "RR", "BR"]

    # sort data by tourney date, id, round
    # from latest to oldest one
    matches.sort_by! do |match|
      [-(match[:tourney_date].to_i), match[:tourney_id], rounds.index(match[:round].to_s)]
    end
  end
end

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
