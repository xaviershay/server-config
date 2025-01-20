require 'json'

class JsonSecrets
  def initialize(filename: "~/.babssecrets.json")
    @filename = File.expand_path(filename)
  end

  def read(name)
    blob.fetch(name).chomp
  end

  def write(name, value)
    blob[name] = value
    File.open(@filename, 'w', 0600) do |f|
      f.write(encode(blob))
    end
    value
  end

  def keys
    blob.keys.sort
  end

  protected

  def blob
    @blob ||= decode(File.read(@filename))
  end

  def encode(data)
    JSON.pretty_generate(data)
  end

  def decode(data)
    JSON.parse(data)
  end
end