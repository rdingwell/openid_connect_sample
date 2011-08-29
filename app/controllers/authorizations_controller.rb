class AuthorizationsController < ApplicationController
  before_filter :require_authentication

  rescue_from Rack::OAuth2::Server::Authorize::BadRequest do |e|
    @error = e
    render :error, status: e.status
  end

  def new
    call_authorization_endpoint
  end

  def create
    call_authorization_endpoint :allow_approval, params[:approve]
  end

  private

  def call_authorization_endpoint(allow_approval = false, approved = false)
    endpoint = AuthorizationEndpoint.new current_account, allow_approval, approved
    rack_response = *endpoint.call(request.env)
    @client, @response_type, @redirect_uri, @scopes = endpoint.client, endpoint.response_type, endpoint.redirect_uri, endpoint.scopes
    respond_as_rack_app *rack_response
  end

  def respond_as_rack_app(status, header, response)
    ["WWW-Authenticate"].each do |key|
      headers[key] = header[key] if header[key].present?
    end
    if response.redirect?
      redirect_to header['Location']
    else
      render :new
    end
  end
end