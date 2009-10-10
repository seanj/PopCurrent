class PopMailer < ActionMailer::Base
  
  def pop_mailer(submission, recipients, message, link)
    @subject = $pop_subject
    @body['message'] = message
    @body['submission'] = submission
    @body['link'] = link
    @recipients = recipients
    @from = 'contact@popcurrent.com'
  end
end