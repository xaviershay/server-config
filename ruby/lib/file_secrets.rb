class FileSecrets
  def read(name)
    ->{ File.read("secrets/#{name}").chomp }
  rescue Errno::ENOENT
    raise "Please place appropriate secret in secrets/#{name}"
  end
end