module Sentry
  class SymmetricSentry
    def encrypt(data, key = nil)
      key = check_for_key!(key)
      des = encryptor      
      #des.encrypt(key)
      des.encrypt
      key = Digest::SHA1.hexdigest(key)
      des.key = key
      data = des.update(data)
      data << des.final
    end
    def decrypt(data, key = nil)
      key = check_for_key!(key)
      des = encryptor
      #des.decrypt(key)
      des.decrypt
      key = Digest::SHA1.hexdigest(key)
      des.key = key
      text = des.update(data)
      text << des.final
    end
  end
end
