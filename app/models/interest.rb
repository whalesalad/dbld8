# == Schema Information
#
# Table name: interests
#
#  id          :integer         not null, primary key
#  name        :string(255)     not null
#  facebook_id :integer(8)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Interest < ActiveRecord::Base
  attr_accessible :facebook_id, :name

  attr_accessor :matched

  default_scope order('name')

  validates_uniqueness_of :name, :case_sensitive => false
  validates_uniqueness_of :facebook_id, :allow_nil => true

  has_and_belongs_to_many :users

  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :id, :index => :not_analyzed
    indexes :name, type: 'string', analyzer: 'snowball'
  end

  def self.search(params)
    tire.search(:per_page => 50) do
      if params[:query].present?
        query { match :name, params[:query], type: 'phrase_prefix' } 
      end
    end
  end

  def to_s
    name
  end

  def as_json(options={})
    result = super({ :only => [:id, :name] })
  end

  def to_indexed_json
    self.to_json
  end
end
