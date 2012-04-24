class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :connect_profiles do |t|
      t.belongs_to :account
      t.string(:name,
        :given_name,
        :family_name,
        :middle_name,
        :website,
        :gender,
        :birthday,
        :zoneinfo, 
        :email,
        :street_address,
        :region,
        :locality,
        :country,
        :postal_code,
        :profile,
        :picture, 
        :locale,
        :phone_number
        )
      t.boolean :verified
      t.timestamps
    end
  end

  def self.down
    drop_table :connect_profiles
  end
end
