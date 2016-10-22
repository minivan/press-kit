module Parser
  def build_url(id)
    "#{main_url}#{id}"
  end

  def load_doc(id)
    Zlib::GzipReader.open("#{page_dir}#{id}.html.gz") { |gz| gz.read }
  end

  def parse_timestring(timestring)
    DateTime.strptime(timestring, "%d.%m.%Y %k:%M").iso8601
  end

  def save(hash)
    page = ParsedPage.new(hash)
    page.save
  end

  def latest_stored_id
    available_pages.last || 0
  end

  def available_pages
    Dir["#{page_dir}*"].map { |f| f.split('.').first.gsub(page_dir, "") }
        .map(&:to_i)
        .sort
  end

  def latest_parsed_id
    ParsedPage.where(source: 'protv').desc(:article_id).limit(1).first.article_id
  rescue
    0
  end

  def progress(id)
    "#{id}/#{latest_stored_id}"
  end

  def run
    (latest_parsed_id+1..latest_stored_id).to_a.each do |id|
      begin
        puts "\nT#{self.class.name}: #{progress(id)}"
        hash = parse(load_doc(id), id)

        if hash
          save(hash)
        else
          puts "NO DATA"
        end
      rescue Errno::ENOENT => err
        puts "NOT SAVED TO DISK"
      end
    end
  end
end
