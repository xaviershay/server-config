class FileSecrets
  def read(name)
    File.read("secrets/#{name}").chomp
  rescue Errno::ENOENT
    raise "Please place appropriate secret in secrets/#{name}"
  end

  def write(name, value)
    File.write("secrets/#{name}", value, 600)
    value
  end

  def keys
    Dir["secrets/*"].map {|x| File.basename(x) }.sort
  end
end