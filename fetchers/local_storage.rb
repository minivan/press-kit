class LocalStorage
  def setup(dir)
    @dir = dir
    create_directory_if_missing
  end

  def latest_page_id
    @latest_page_id ||= get_latest_page_id
  end

  def save(page, id)
    Zlib::GzipWriter.open(@dir + id.to_s + ".html.gz") do |gz|
      gz.write page
    end
  end

private

  def get_latest_page_id
    Dir["#{@dir}*"].map{ |f| f.split('.').first.gsub(@dir, "") }
        .map(&:to_i)
        .sort
        .last || 0
  end

  def create_directory_if_missing
    FileUtils.mkdir_p @dir
  end
end
