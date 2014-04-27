require 'json'
require 'pry'
require "i18n"

SQUASHED_DIR = "data/squashed/"

Person = Struct.new(:key, :name, :terms)

people = [
  Person.new(:filat,   "V. Filat",     ["Filat"]),
  Person.new(:voronin, "V. Voronin",   ["Voronin"]),
  Person.new(:tanase,  "A. Tănase",    ["Tanase"]),
  Person.new(:dodon,   "I. Dodon",     ["Dodon"]),
  Person.new(:ghimpu,  "M. Ghimpu",    ["Ghimpu"]),
  Person.new(:urechean,"S. Urechean",  ["Urechean"]),
  Person.new(:lupu,    "M. Lupu",      ["Lupu"]),
  Person.new(:leanca,  "I. Leancă",    ["Leanca"]),
  Person.new(:plaho,   "V. Plahotniuc",["Plahotniuc"]),
  Person.new(:chirt,   "D. Chirtoacă", ["Chirtoaca"]),
  Person.new(:godea,   "M. Godea",     ["Godea"]),
  Person.new(:diacov,  "D. Diacov",    ["Diacov"]),
  Person.new(:strelet, "V. Streleţ",   ["Strelet"]),
  Person.new(:sirbu,   "S. Sârbu",     ["Sirbu", "Sarbu"]),
  Person.new(:hadarca, "I. Hadârcă",   ["Hadarca", "Hadirca"]),
  Person.new(:nantoi,  "O. Nantoi",    ["Nantoi"]),
  Person.new(:rosca,   "I. Roşca",     ["Rosca"]),
  Person.new(:formuzal,"M. Formuzal",  ["Formuzal"]),
  Person.new(:timofti, "N. Timofti",   ["Timofti"]),
  Person.new(:selin,   "V. Şelin",     ["Selin"]),
  Person.new(:sandu,   "M. Sandu",     ["Sandu"]),
  Person.new(:usatii,  "R. Usatîi",    ["Usatii", "Usatai"])
]

data = JSON.parse(File.read(SQUASHED_DIR + "all.json"))
puts "Replacing the timestamps..."
data.each do |item|
  item["time"] = DateTime.parse(item["datetime"])
end

result = {}

(2008..2014).each do |year|
  year_filtered = data.select { |e| e["time"].year == year }
  result[year.to_s] = {}

  (1..12).each do |month|
    month_filtered = year_filtered.select { |e| e["time"].month == month }
    puts "Working with #{month}.#{year}"

    full_text  = month_filtered.map { |e| e["content"] }.join(" ")
    month_data = {}
    month_total = month_filtered.count
    people.each do |person|
      total_occurences = 0

      month_filtered.each do |article|
        if person.terms.any? { |term| article["content"].scan(term).count > 0 }
          total_occurences += 1
        end
      end

      occurences = if month_total.zero?
        0.0
      else
        (total_occurences.to_f / month_total).round(2)
      end

      month_data[person.key] = {
        name: person.name,
        occurences: occurences
      }
    end

    result[year.to_s][month.to_s] = month_data
  end
end

File.write("dataset.json", result.to_json)


