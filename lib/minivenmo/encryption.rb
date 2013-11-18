class MiniVenmo
  ENCRYPTION_KEY = OpenSSL::Digest::SHA256.new(File.read('lib/secret').chomp).digest
end
