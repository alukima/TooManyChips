class User < ActiveRecord::Base
  attr_accessible :name, :email, :password
  has_many :events
  has_many :assigned_items, :class_name => 'AssignedItem', :foreign_key => 'user_id'
  validates :name, :length  => {:minimum => 2, :too_short  => "must have at least 2 letters"}
  validates :email, :uniqueness => {:case_sensitive => false, :message => "has already been taken"}, 
  :format => {:with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, 
  :message => "must be a valid format" }
  validates :password, :length => {:minimum => 6, :too_short  => "must have at least 6 characters"}, unless: :guest? 
  validates_confirmation_of :password
  has_many :assigned_items, :dependent => :destroy
  has_many :event_items, :through => :assigned_items
  attr_accessible :name, :email, :url, :assigned_items_attributes, 
  :event_items_attributes, :assigned_items, :event_items, :guest
  belongs_to :event, :class_name => 'User', foreign_key: 'user_id'
  accepts_nested_attributes_for :assigned_items, :event_items
  # after_save :registration_emails!
  before_create :set_url
 require 'bcrypt'
  attr_reader :password
  include ActiveModel::SecurePassword::InstanceMethodsOnActivation
  

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.password = SecureRandom.hex(4)
      user.save!
    end
  end

  def set_url
     self.url ||= SecureRandom.urlsafe_base64 if self.guest
  end


  def registration_emails!
    # schedule_result_email unless self.result_date == nil
    send_email
  end

  # def schedule_result_email
  #   EmailWorker.perform_at(self.result_date, self.user_id, self.id, 'result')
  # end

  def get_contributions(id)
    self.assigned_items.select { |item| item if (item.event_item.event_id == id) }
  end

  def send_email
    EmailWorker.perform_async(self.id)
  end
  
   def contributions(id)
    self.assigned_items.select { |item| item if (item.event_item.event_id == id) }
  end

  def set_url
    self.url ||= SecureRandom.urlsafe_base64
  end


end
  



