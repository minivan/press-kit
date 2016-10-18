class Word
  include Mongoid::Document

  store_in collection: "words"
  belongs_to :parsed_page

  field :source,       type: String
  field :normalized,   type: String
  field :racai_string, type: String
  field :pos,          type: String
  field :day,          type: Integer
  field :month,        type: Integer
  field :year,         type: Integer

  index({ datetime: 1 }, {name: "words_datetime_index"})
  index({ month: 1},     {name: "words_month_index"})
  index({ day: 1},       {name: "words_day_index"})
  index({ year: 1},      {name: "words_year_index"})

  def self.save_racai_word!(split_string, parsed_page)
    Word.create!(source:       parsed_page.source,
                 year:         parsed_page.datetime.year,
                 month:        parsed_page.datetime.month,
                 day:          parsed_page.datetime.day,
                 racai_string: split_string.join("\t"),
                 normalized:   split_string[2],
                 pos:          split_string[1],
                 parsed_page:  parsed_page)
  end
end
