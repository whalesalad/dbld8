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

  validates_presence_of :user

  def to_s
    token
  end

  def as_json(options={})
    return { :user_id => user_id, :token => token }
  end
  
  private

  def generate_token
    require 'openssl'
    digest = OpenSSL::Digest::Digest.new('sha1')
    self.token = OpenSSL::HMAC.hexdigest(digest, Time.now.to_i.to_s, "#{self.user.id}:dbld8")
  end

end
