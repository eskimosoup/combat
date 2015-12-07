class Mailer < ActionMailer::Base

  def mail_shot(to, from, subject, body)
    @recipients = to
    @from = from
    @subject = subject
    @body[:body] = body
  end

  def contact_recieved(dump)
    unless /\S+?@\S+?\.\S+?/ =~ dump[:email]
      dump[:email] = SiteProfile.first.email
      @subject = 'Contact form filled out (no reply email address supplied)'
    else
      @subject = 'Contact form filled out'
    end
    @body[:dump] = dump
    @recipients = SiteProfile.find(:first).email
    @from = dump[:email]
  end

  def welcome_admin(admin, password)
    @subject = 'T Media Admin'
    @body[:password] = password
    @body[:name] = admin.name
    @recipients = admin.email
    @from = SiteProfile.first.email
  end

  def forgotten_password(admin, password)
    @subject = 'T Media Admin'
    @body[:password] =  password
    @body[:name] = admin.name
    @recipients = admin.email
    @from = SiteProfile.first.email
  end

  def new_admin(admin)
    @subject = 'a new admin has signed up'
    @body[:admin] = admin
    @recipients = ['george@tmedia.co.uk', 'hannah@tmedia.co.uk', 'robbie@tmedia.co.uk']
    @from = SiteProfile.first.email
  end

  def content_changed (content, content_type)
    @subject    = "A #{content_type} has changed"
    @body[:content] = content
    @recipients = 'info@tmedia.co.uk'
    @from       = 'demo@tmediasolutions.co.uk'
  end
end
