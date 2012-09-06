class AuthToken < ActiveRecord::Base
  before_create :generate_token
  
  attr_accessible :user
  
  belongs_to :user

  def as_json(options={})
    { :user_id => user_id, :token => token }
  end
  
  private

  def generate_token
    require 'openssl'
    digest = OpenSSL::Digest::Digest.new('sha1')
    self.token = OpenSSL::HMAC.hexdigest(digest, self.user.created_at.to_s, "#{self.user.id}:dbld8")
  end

end
