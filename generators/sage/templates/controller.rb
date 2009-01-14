class <%= controller_name %> < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :authenticate
  
  <% unless options[:no_upload] %>
  def upload
    # UPLOAD CODE
  end
  <% end -%>
  
  <% unless options[:no_download] %>
  def download
    render :xml => SageDownload.create!
  end
  
  def import
    SageImport.create!(:xml => request.body.read)
    render :nothing => true
  end
  <% end -%>

  private
  
    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == 'sageuser' && password == '<%= password %>'
      end
    end

end
