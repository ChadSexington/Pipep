class User < ActiveRecord::Base

  require 'digest/sha1'

  has_one :transmission

  def password=(pass)
    @password=pass
    self.salt = random_string(10) if not self.salt
    self.hashed_password = encrypt(@password, self.salt)
  end

  def self.authenticate(username, pass)
    user = User.where(:username => username).first
    if user
      if encrypt(pass, user.salt) == user.hashed_password
        user
      else
        false
      end
    else
      Rails.logger.error "User that does not exist attempted to log in: #{user}"
      false
    end
  end

private

  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass+salt)
  end

  def encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass+salt)
  end

  def random_string(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newstr = ""
    1.upto(len) { |i| newstr << chars[rand(chars.size-1)] }
    return newstr
  end

end
