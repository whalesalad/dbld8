# == Schema Information
#
# Table name: auth_tokens
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  token      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

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
