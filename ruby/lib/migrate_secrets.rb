require 'file_secrets'
require 'json_secrets'
require 'keyctl_json_secrets'

raise "you've already done this"

from = JsonSecrets.new
to = KeyctlJsonSecrets.new

from.keys.each do |key|
  to.write(key, from.read(key))
end