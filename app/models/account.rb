class Account < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  has_one :profile,     class_name: 'Connect::Profile'
  has_many :clients, :through=>:authorizations, :uniq=>true
  has_many :access_tokens
  has_many :authorizations
  has_many :id_tokens
  has_many :pairwise_pseudonymous_identifiers

  before_validation :setup, on: :create

  validates :identifier, presence: true, uniqueness: true

  def to_response_object(access_token)
    user_info = profile.user_info
    unless access_token.accessible?(Scope::PROFILE)
      user_info.all_attributes.each do |attribute|
        user_info.send("#{attribute}=", nil) unless access_token.accessible?(attribute)
      end
    end
    user_info.email        = nil unless access_token.accessible?(Scope::EMAIL)   || access_token.accessible?(:email)
    user_info.address      = nil unless access_token.accessible?(Scope::ADDRESS) || access_token.accessible?(:address)
    user_info.phone_number = nil unless access_token.accessible?(Scope::PHONE)   || access_token.accessible?(:phone)
    user_info.user_id = if access_token.client.ppid?
      PairwisePseudonymousIdentifier.find_or_create_by_sector_identifier(access_token.client.sector_identifier).identifier
    else
      identifier
    end
    user_info
  end

  private

  def setup
    self.identifier = SecureRandom.hex(8)
    self.profile = Connect::Profile.new
  end
  
end