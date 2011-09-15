# Created by IntelliJ IDEA.
# User: jimsun
# Date: Aug 1, 2008
# Time: 11:50:14 AM
# To change this template use File | Settings | File Templates.
require "MyRubyUtil"
include MyRubyUtil
require 'InetSoft'
require 'WatirHandler'
require 'WeblogicHandler'
require 'WebsphereHandler'
require 'TomcatHandler'
require 'test/unit'

# Tests to verify that
#   1. the webservers can be started propertly
#   2. the sree web app can be deployed propertly

class TC_ServerRestartTest < Test::Unit::TestCase
   def setup
     @server_handlers = [         

    #  TomcatHandler.new, WebsphereHandler.new, WeblogicHandler.new
     TomcatHandler.new
   ]
   end

   def teardown
     begin
       3.downto(1) do |i|
         leftover_ie = IE.attach(:title, /Welcome to BEA Weblogic|InetSoft Examples/)
         leftover_ie.wait
         leftover_ie.close         
       end
     rescue
       #
     end

   end   
 
   
   def test_webserver_restart
      # testing if the webserver stop/start routine works
      @server_handlers.each {|s|
        started=false
        begin
          puts "================================================================"
          s.restart_webserver
          started=s.is_webserver_up?(s.webserver_name)
        rescue
          $?
        end
        puts "started = #{started}"
        assert(started, "Webserver not started: #{s.webserver_name}")
        # s.stop_webserver
      }
   end

   def test_redeploy_sree
     # 1. testing if the Inetsoft report can be depolyed properly
     # 2. better to run after the test of test_webserver_restart is passed
     @server_handlers.each {|s|
       deployed=false
       begin          
          puts "================================================================"
          s.redeploy_sree
          deployed = s.is_sree_up?(s.webserver_name)
       rescue => detail       
            print detail.backtrace.join("\n")
       end
       puts "deployed = #{deployed}"
       assert(deployed, "InetSoft not deployed properly in webserver: #{s.webserver_name}")
       s.stop_webserver
      }
    end



end









