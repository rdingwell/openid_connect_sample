class Connect::ProfilesController < ApplicationController
  before_filter  :authenticate_account!
  
  def show
    @profile = current_account.profile
  end
 
  def create
    current_account.profile = Profile.new(params[:connect_profile])
    current_account.profile.save
    redirect_to :show
  end
  
  def edit
    @profile = current_account.profile
  end
  
  def update
    current_account.profile.update_attributes(params[:connect_profile])
    current_account.profile.save
    redirect_to connect_profile_path
  end
  
  
end