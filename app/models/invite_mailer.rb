class InviteMailer < ActionMailer::Base

  def invite(recipients, message)
    @subject = $invite_subject
    @body['message'] = message
    @recipients = recipients
    @from = 'contact@popcurrent.com'
    @sent_on    = Time.now
    @headers    = {}
  end

end
