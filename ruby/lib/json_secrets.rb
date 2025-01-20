require 'json'

class JsonSecrets
  def initialize(filename: File.expand_path("~/.babssecrets.json"))
    @filename = filename
  end

  def read(name)
    blob.fetch(name).chomp
  end

  def write(name, value)
    blob[name] = value
    File.open(@filename, 'w', 0600) do |f|
      f.write(JSON.pretty_generate(blob))
    end
    value
  end

  def keys
    blob.keys.sort
  end

  private

  def blob
    @blob ||= JSON.parse(File.read(@filename)) rescue {}
  end
end