require 'net/smtp'

class LeapTest

  TEST_EMAIL_USER = "test_user_email"
  TEST_BAD_USER = "test_user_bad"

  MSG_BODY = %(Since it seems that any heart which beats for freedom has the right only to a
lump of lead, I too claim my share. If you let me live, I shall never stop
crying for revenge and I shall avenge my brothers. I have finished. If you are
not cowards, kill me!

--Louise Michel)

  def send_email(recipient, options={})
    sender = options[:sender] || recipient
    helo_domain = property('domain.full_suffix')
    headers = {
      "Date" => Time.now.utc,
      "From" => sender,
      "To" => recipient,
      "Subject" => "Test Message",
      "X-LEAP-TEST" => "true"
    }.merge(options[:headers]||{})
    message = []
    headers.each do |key, value|
      message << "#{key}: #{value}"
    end
    message << ""
    message << MSG_BODY
    Net::SMTP.start('localhost', 25, helo_domain) do |smtp|
      smtp.send_message message.join("\n"), recipient, sender
    end
  end

  def assert_send_email(recipient, options={})
    begin
      send_email(recipient, options)
    rescue IOError, Net::OpenTimeout,
           Net::ReadTimeout, Net::SMTPError => e
      fail "Could not send mail to #{recipient} (#{e})"
    end
  end

end