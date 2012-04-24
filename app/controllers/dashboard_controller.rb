class DashboardController < ApplicationController
  before_filter  :authenticate_admin!

  def show
    @clients = Client.all
  end
end
