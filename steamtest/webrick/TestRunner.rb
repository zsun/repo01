# Created by IntelliJ IDEA.
# User: jimsun
# Date: Aug 1, 2008
# Time: 11:50:14 AM
# To change this template use File | Settings | File Templates.

#puts `NET STOP "Apache Tomcat"`
# puts `NET START "Apache Tomcat"`
#puts `"C:\\Tomcat 6.0.18\\bin\\tomcat6.exe" //RS//Tomcat6`

# $LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'C:/depot/tools/ruby/win32/lib/ruby/1.8')
require 'MyRubyUtil.rb'
require 'AutoItHandler.rb'
require 'WatirHandler.rb'
require 'TomcatHandler.rb'
require 'WeblogicHandler.rb'
require 'WebsphereHandler.rb'

include MyRubyUtil

puts ENV['CURRENT_BRANCH']
puts ENV['PATH']
puts current_branch_dir()
exit
AutoItHandler.new
exit


puts WeblogicHandler.new.sree_properties_path("weblogic")

exit

# to try to deploy InetSoft into a particular webserver
WeblogicHandler.new.redeploy_sree
exit


# to try to do webserver restart stuff
ws = WebsphereHandler.new
ws.restart_webserver
ws.redeploy_sree
exit

# to try to see if InetSoft app up running in particular webserver
puts (WebsphereHandler.new.is_sree_up?("websphere"))                                
exit



#WatirHandler.new.sree_portal_login_no_permission
# update_sree_web_services