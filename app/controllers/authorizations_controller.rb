class AuthorizationsController < ApplicationController
  before_filter :authenticate_account!

  rescue_from Rack::OAuth2::Server::Authorize::BadRequest do |e|
    @error = e
    logger.info e.backtrace.join("\n")
    render :error, status: e.status
  end


  def index
    @authorizations = current_account.authorizations
  end
  
  def show
    @authorization = current_account.authorizations.find(params[:id])
  end
  
  
  def destroy
    @authorizations = current_account.authorizations.find_by_client_id(params[:id])
    @authorizations.destroy
    redirect_to root_path
  end
  
  
  def new
    client = Client.find_by_identifier(params[:client_id])
    prompt = params[:prompt] || "" 
    allow_approval = current_account.authorizations.find_all_by_client_id(client.id).length > 0
    approve =  prompt != "consent" 
    call_authorization_endpoint allow_approval, approve
  end

  def create
    call_authorization_endpoint :allow_approval, params[:approve]
  end

  private

  def call_authorization_endpoint(allow_approval = false, approved = false)
    endpoint = AuthorizationEndpoint.new current_account, allow_approval, approved
#    binding.pry
    rack_response = *endpoint.call(request.env)
    @client, @response_type, @redirect_uri, @scopes, @_request_, @request_uri, @request_object = *[
      endpoint.client, endpoint.response_type, endpoint.redirect_uri, endpoint.scopes, endpoint._request_, endpoint.request_uri, endpoint.request_object
    ]
    # if (
    #       !allow_approval &&
    #       (max_age = @request_object.try(:id_token).try(:max_age)) &&
    #       current_account.last_sign_in_at < max_age.seconds.ago
    #     )
    #       flash[:notice] = 'Exceeded Max Age, Login Again'
    #       sign_out
    #       require_authentication
    #     end
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
