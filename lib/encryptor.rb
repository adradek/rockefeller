require "openssl"
require "base64"
require "securerandom"

# For secure encryption of sensitive data based on a weak password: psw + random salt -> key -> secret
class Encryptor
  ADDITION = "unbearable lightness of being"

  attr_reader :password, :salt

  def initialize(password)
    @password = "#{password}#{ADDITION}"
  end

  def encrypt(bin_data)
    @salt = SecureRandom.random_bytes(16)
    nonce = SecureRandom.random_bytes(12) # 12 bytes for GCM

    cipher = OpenSSL::Cipher.new("aes-256-gcm")
    cipher.encrypt
    cipher.key = key
    cipher.iv = nonce
    encrypted = cipher.update(bin_data) + cipher.final
    tag = cipher.auth_tag

    [salt, nonce, tag, encrypted].map { |x| Base64.strict_encode64(x) }.join("\n")
  end

  def decrypt(based_encryption)
    lines = based_encryption.lines.map(&:chomp)
    @salt, nonce, tag, encrypted = lines.map { |l| Base64.decode64(l) }

    cipher = OpenSSL::Cipher.new("aes-256-gcm")
    cipher.decrypt
    cipher.key = key
    cipher.iv = nonce
    cipher.auth_tag = tag

    cipher.update(encrypted) + cipher.final
  end

  def key
    @key ||= OpenSSL::PKCS5.pbkdf2_hmac(password, salt, 200_000, 32, "sha256")
  end
end
