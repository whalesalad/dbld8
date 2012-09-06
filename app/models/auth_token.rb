class AuthToken < ActiveRecord::Base
  before_create :generate_token

  belongs_to :user
  
  private

  def generate_token
    require 'openssl'
    digest = OpenSSL::Digest::Digest.new('sha1')
    self.token = OpenSSL::HMAC.digest(digest, self.user.created_at.to_s, "#{self.user.id}:dbld8")
  end

end
