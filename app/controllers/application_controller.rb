class ApplicationController < ActionController::API
  before_action :disable_cors
  before_action :identify_user

  attr_reader :current_user

  private

  def disable_cors
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  def identify_user
    @current_user = request.headers['Authorization']
  end
end
