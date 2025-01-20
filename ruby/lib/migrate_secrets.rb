require 'file_secrets'
require 'json_secrets'

raise "you've already done this"

from = FileSecrets.new
to = JsonSecrets.new

from.keys.each do |key|
  to.write(key, from.read(key))
end