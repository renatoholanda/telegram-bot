require 'telegram_bot'
require 'net/http'
require './message.rb'

class MonitorBot
  def initialize
    @sleep_time = $config["sleep_time"]["default"]
    @is_down = false;
    @bot = TelegramBot.new(token: $config["bot_token"])

    # @bot.get_updates(fail_silently: true) do |message|
    #   puts "@#{message.from.username}: #{message.text}"
    #   command = message.get_command_for(@bot)

    #   message.reply do |reply|
    #     case command
    #     when /register/i
    #       ids = File.readlines('ids.txt');
    #       unless ids.include? message.chat.id
    #         ids << message.chat.id
    #         File.open("ids.txt", 'w+') do |f|
    #           ids.each do |id|
    #             f.puts(id)
    #           end
    #         end
    #       end
    #       reply.text = "#{message.from.first_name}, register success."
    #     else
    #       reply.text = "#{message.from.first_name}, have no idea what #{command.inspect} means."
    #     end

    #     puts "sending #{reply.text.inspect} to @#{message.from.username}"
    #     reply.send_with(@bot)
    #   end
    # end
  end

  def init_loop
    sleep_time = $config["sleep_time"]
    messages = $config["messages"]
    send_message messages["connected"]

    loop do
      begin
        url = URI.parse($config["site_url"])
        req = Net::HTTP.new(url.host, url.port)
        req.use_ssl = true
        data = req.get(url.request_uri)
        status = data.code.to_i
        
        if status == 200 && @is_down
          @is_down = false;
          @sleep_time = sleep_time["default"]
          send_message messages["return_down"]
        elsif status == 200
          puts "#{messages["ok"]} #{status}"
        else
          @is_down = true;
          @sleep_time = sleep_time["error"]
          send_message "#{messages["check_it"]} #{status}"
        end
      rescue => exception
        @is_down = true;
        @sleep_time = sleep_time["error"]
        send_message messages["down"]
      end
      
      sleep(@sleep_time)
    end
  end
  
  def send_message(text)
    puts text
    ids = File.readlines('ids.txt');

    ids.each do |id|
      msg = Message.new
      msg.chat_id = id
      msg.text = text
      @bot.send_message(msg)
    end
  end
end

