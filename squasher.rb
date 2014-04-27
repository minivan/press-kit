require 'json'
require 'i18n'

PARSED_DIR   = "data/parsed/"
SQUASHED_DIR = "data/squashed/"

Person = Struct.new(:key, :name, :terms)
@people = [
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

data = []

File.write(SQUASHED_DIR + "all.json", "")

def has_mention?(text)
  @people.each do |person|
    person.terms.each do |term|
      return true unless text.scan(term).empty?
    end
  end
  false
end

def build_url(id)
  "http://unimedia.info/stiri/-#{id}.html"
end

most_recent = Dir[PARSED_DIR + "*"].max_by { |f| File.mtime(f) }
parsed_time = File.mtime(most_recent)
squashed_time = File.mtime(SQUASHED_DIR + "all.json")

if squashed_time < parsed_time
  # there's nothing new
  puts "Nothing new parsed"
  exit
end

Dir[PARSED_DIR + "*"].each do |filename|
  puts "Loading #{filename}"
  article = JSON.parse(File.read(filename))
  id = filename.gsub(PARSED_DIR, "")
  article["id"]  = id
  article["url"] = build_url(id)
  next unless article["content"]

  article["content"] = I18n.transliterate(article["content"])

  if has_mention?(article["content"])
    data << article
  end
end

sorted = data.sort_by {|elem| elem["id"].to_i }
File.write(SQUASHED_DIR + "all.json", JSON.pretty_generate(sorted))
