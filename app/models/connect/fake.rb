class Connect::Fake < ActiveRecord::Base
  belongs_to :account

  def user_info
    OpenIDConnect::ResponseObject::UserInfo::OpenID.new(
      name:         name,
      given_name:   given_name,
      family_name:  family_name,
      middle_name:  middle_name,
      website:      website,
      gender:       gender,
      birthday:     birthday,
      zoneinfo:     zoneinfo, 
      email:        email,
      address:      address,
      profile:      profile,
      picture:      picture, 
      locale:       locale,
      phone_number: phone_number,
      verified: false
    )
  end

  class << self
    def authenticate
      Account.create!(fake: create!)
    end
  end
end
