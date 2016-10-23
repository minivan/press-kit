class BatchRacaiFetcher
  def self.process!(articles)
    builder = RacaiBuilder.new(articles)
        .to_sgml
        .tokenize
        .tag
        .lemmatize
        .chunk
        .to_utf8

    result = builder.build
    save!(result)
  rescue => e
    p "oops!"
    p e.message
    sleep 60
    retry
  end

private
  def self.save!(result)
    result.each do |page, page_result|
      page_result.split(/\n/).each do |racai_string|
        split_string = racai_string.split(/\t/)
        # it's 4 because the racai result represent 4 elements separated by \t
        if split_string.count == 4
          Word.save_racai_word!(split_string, page)
        end
      end
      page.has_words = true
      page.save
    end
  end
end
