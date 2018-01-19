require 'yaml'
$config = YAML.load_file('config.yml')

require './monitor_bot.rb'

monitor = MonitorBot.new
monitor.init_loop