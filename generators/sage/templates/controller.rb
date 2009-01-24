class <%= controller_name %> < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :authenticate
  
  def upload
  <% unless options[:no_upload] %>
    # UPLOAD CODE
  <% end -%>
    render :nothing => true
  end
  
  def download
  <% unless options[:no_download] %>
    render :xml => SageDownload.create!
  <% end %>
  end
  
  def import
  <% unless options[:no_download] %>
    SageImport.create!(:xml => request.body.read)
  <% end -%>
    render :nothing => true
  end

  private
  
    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == 'sageuser' && password == '<%= password %>'
      end
    end

end
