# == Schema Information
#
# Table name: purchases
#
#  id         :integer         not null, primary key
#  user_id    :integer         not null
#  identifier :string(255)     not null
#  receipt    :text            not null
#  verified   :boolean
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Purchase < ActiveRecord::Base
  include Concerns::EventConcerns
  
  attr_accessor :verified_receipt

  after_commit :verify_async, :on => :create
  after_commit :create_purchase_event!, :on => :create

  attr_accessible :identifier, :receipt
  
  validates_presence_of :user_id, :receipt
  validates_presence_of :coin_package, 
    :message => "A valid coin package 'identifier' must be supplied."

  belongs_to :user

  belongs_to :coin_package,
    foreign_key: 'identifier',
    primary_key: 'identifier',
    class_name: 'CoinPackage',
    counter_cache: true,
    inverse_of: :purchases,
    readonly: true

  scope :verified, where(:verified => true)
  scope :unverified, where(:verified => nil)
  scope :invalid, where(:verified => false)

  def to_s
    "#{user.full_name} purchased #{coin_package}"
  end

  def status
    case verified
    when true
      :verified
    when false
      :invalid
    when nil
      :pending
    end
  end

  # def receipt=(data)
  #   self[:receipt] = Base64.encode64(data)
  # end

  def verified_receipt
    @verified_receipt ||= Venice::Receipt.verify(receipt)
  end

  def receipt_data
    @verified_receipt.to_h if verified_receipt
  end

  def verified?
    verified == true
  end

  def unverified?
    verified.nil?
  end

  def invalid?
    verified == false
  end

  def verify!
    self.verified = !!verified_receipt
    save!
  end

  def coins
    coin_package.coins
  end

  def create_purchase_event!
    PurchaseEvent.create(:user => user, :related => self, :coins => coins)
  end

  def verify_async
    ReceiptVerificationWorker.perform_async(id)
  end
end
