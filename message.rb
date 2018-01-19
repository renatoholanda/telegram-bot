class Message
  attr_accessor :chat_id
  attr_accessor :text
  attr_accessor :chat_friendly_name
  attr_accessor :parse_mode

  def to_h
    message = {
      text: text,
      chat_id: chat_id,
      parse_mode: "markdown"
    }

    message
  end
end