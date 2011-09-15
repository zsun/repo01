# Created by IntelliJ IDEA.
# User: jimwang
# Date: Aug 6, 2009
# Time: 3:23:30 PM
# To change this template use File | Settings | File Templates.
$:.unshift File.join(File.dirname(__FILE__), 'watir-1.5.3')
require File.basename(__FILE__) + 'WatirItHandler'
require File.basename(__FILE__) + 'Handler'
require File.basename(__FILE__) + 'MyRubyUtil'


autoHandler = WatirHandler.new()
argumentHash = {}
index = 0
# Basically each even numbered command line argument is a parameter name
# And each odd one is a parameter value.
# Assuming that we have an even number of arguments
while index < ARGV.length
  argumentHash[ARGV.length] = ARGV.length + 1
  index = index + 2
end
puts(autoHandler.handle(argumentHash))

