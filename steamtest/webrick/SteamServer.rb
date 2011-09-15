# Created by IntelliJ IDEA.
# User: jimsun
# Date: Apr 14, 2008
# Time: 10:13:07 AM
# To change this template use File | Settings | File Templates.

# note: add the dir of this file to your MYRUBYLIB environment variable
#   Here is what I have for RUBYLIB
#      C:\depot\tools\ruby\win32\lib\ruby\gems\1.8\gems\watir-1.5.3;C:\depot\tools\ruby\win32\lib;
#      C:\depot\tools\ruby\win32\lib\ruby\1.8;C:\depot\tools\ruby\win32\lib\ruby\site_ruby\1.8;
#      C:\depot\tools\ruby\steamtest\webrick

require 'MyRubyUtil.rb'
require 'AutoItHandler.rb'
require 'WatirHandler.rb'
require 'TomcatHandler.rb'
require 'WeblogicHandler.rb'
require 'WebsphereHandler.rb'
                                          


require 'webrick'
include WEBrick

class WEBrick::HTTPServlet::AbstractServlet
  include MyRubyUtil  
end

$handlers = {
        "autoit"    => AutoItHandler.new,
        "watir"     => WatirHandler.new,         
        "tomcat"    => TomcatHandler.new,
        "weblogic"  => WeblogicHandler.new,
        "websphere" => WebsphereHandler.new
        }
def list_of_handlers
  $list_of_handlers = ""
  $handlers.each_key { |key|  $list_of_handlers += key+" " }
end

class MasterServlet < WEBrick::HTTPServlet::AbstractServlet                                          
   def initializ
      #
    end

    def do_GET(request, response)
      puts "url requested: #{request.query_string}"
      current_time =Time.now.to_s

      handler_name = request.query['handler']
      puts "handler_name = #{handler_name}"
      puts "query = #{request.query}"
      if handler_name =~/lookup/i
        #http://localhost:8013/rubyhelper?handler=lookup
        response.body = service_looup("#{$steam_server[:ServerName]}:#{$steam_server[:Port]}")
        response.status = 200
      elsif handler_name == 'shutdown'
        response.body = 'shutting down'
        response.status = 200
        Thread.new {
          sleep(1)
          $steam_server.shutdown
        }
      else
        handler=$handlers[handler_name]
        if (handler != nil)
          response.body = handler.handle(request.query)
          response.status = 200
        else
          puts "page can not be found at #{request.query_string}"
          info = "The available handles are: " + list_of_handlers
          response.body = "Error: Ruby server does not have such handler #{handler_name} \n"
          response.status = 404
        end
      end

      response['Content-Type'] = 'text/plain'
   end
end


# ----------------------------------------------
# Create an HTTP server
begin
  $steam_server = HTTPServer.new(
    :Port            => 8013,
    :DocumentRoot    => "/usr/local/apache/htdocs/"
  )
rescue Errno::EBADF
  puts "*** failed to start MyRubyServer in the first attempt, try again ..."

  include MyRubyUtil  
  clean_unecessary_processes

  TomcatHandler.new.stop_webserver
  #WeblogicHandler.new.stop_webserver
  #WebSphereHandler.new.stop_webserver
  retry
end

$steam_server.mount("/rubyhelper", MasterServlet)

# When the server gets a control-C, kill it
trap("INT"){ $steam_server.shutdown }

$steam_server.start
