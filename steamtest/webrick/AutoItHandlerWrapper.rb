require 'rubygems'
gem 'win32-process', '=0.5.1'
gem 'windows-pr', '=0.6.2'

$:.unshift File.join(File.dirname(__FILE__), 'watir-1.5.3')
require 'watir'
require 'watir/contrib/enabled_popup'
require 'watir/dialog'
require 'watir/winClicker'

require File.dirname(__FILE__) + '/Handler'
require File.dirname(__FILE__) + '/MyRubyUtil'
require File.dirname(__FILE__) + '/AutoItHandler'



autoHandler = AutoItHandler.new
argumentHash = {}
index = 0
# Basically each even numbered command line argument is a parameter name
# And each odd one is a parameter value.
# Assuming that we have an even number of arguments
while index < ARGV.length
  puts(ARGV[index] + " " + ARGV[index + 1])
  argumentHash[ARGV[index]] = ARGV[index + 1]
  index = index + 2 
end

puts(autoHandler.handle(argumentHash))



 