class <%= controller_name %> < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :authenticate

  def upload
    # UPLOAD CODE
  end
  
  def download
    render :xml => SageDownload.create!
  end
  
  def import
    # IMPORT CODE
  end

  private
  
    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == 'sageuser' && password == '<%= password %>'
      end
    end

end
