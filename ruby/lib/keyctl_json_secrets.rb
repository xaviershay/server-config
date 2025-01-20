require 'openssl'
require 'base64'

require 'json_secrets'

class KeyctlJsonSecrets < JsonSecrets
  def initialize(filename: "../../secrets.encrypted")
    super(filename: File.expand_path(filename, __FILE__))
  end

  def system_key
    @system_key ||= begin
      key_id = `keyctl search @u user babs_system_key`.chomp
      raise "Need to run bin/set-system-key" unless $?.success?
      key = `keyctl print #{key_id}`.chomp
      raise "Error reading key from keyctl" unless $?.success?
      Base64.strict_decode64(key)
    end
  end

  # To be used when initialising a new system and stored in separate credential
  # management
  def new_random_key
    Base64.strict_encode64(build_cipher.random_key)
  end

  def encode(data)
    cipher = build_cipher
    cipher.encrypt
    cipher.key = system_key

    iv = cipher.random_iv
    cipher.auth_data = ''

    encrypted = cipher.update(JSON.pretty_generate(data)) + cipher.final
    auth_tag = cipher.auth_tag

    x = [iv, auth_tag, encrypted].map {|x| Base64.strict_encode64(x) }
    x.to_json
  end

  def decode(data)
    iv, auth_tag, encrypted = *JSON.parse(data).map {|x| Base64.strict_decode64(x) }

    decipher = build_cipher
    decipher.decrypt
    decipher.key = system_key
    decipher.iv = iv
    decipher.auth_tag = auth_tag
    decipher.auth_data = ''

    JSON.parse(decipher.update(encrypted) + decipher.final)
  rescue ArgumentError
    raise "Invalid system key!"
  end

  def build_cipher
    OpenSSL::Cipher.new('aes-256-gcm')
  end
end