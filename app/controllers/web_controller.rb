class WebController < ApplicationController

  before_filter :get_content_page, :only => [:content1, :content2, :content3, :content4, :content5]

  layout WEBLAYOUT

  def index
    redirect_to :action => :content1
  end

  def contact
    @site_profile = SiteProfile.first
  end

  def contact_recieved
    Mailer.deliver_contact_recieved(params[:customer])
    redirect_to :action => 'thank_you'
  end

end
