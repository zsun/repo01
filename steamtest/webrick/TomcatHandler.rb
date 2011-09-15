# Created by IntelliJ IDEA.
# User: jimsun
# Date: Jul 23, 2008
# Time: 3:39:43 PM
# To change this template use File | Settings | File Templates.

require 'MyRubyUtil'
require 'InetSoft'

=begin
   create a method to handle report server:
     -- assume the report tomcat server running on 7070
       1. stop the report tomcat server
           RunCommand.ExecuteNoWait( "c:\\apache-tomcat-6.0.14\\bin\\catalina stop" )
        2. delete the sree folder if existed
        3. get CC port number and write into the sree.properties
        4. build war file and copy into the tomcat webApps folder
        5. start up the report tomcat server
=end
class TomcatHandler  < InetSoft

  attr_reader :sreeBatFileDir

  def initialize    
    @sreeBatFileDir= Dir.pwd
    @sreeManagerUrl = "http://localhost:"+ sreePort + "/sree/EnterpriseManager"
    @tomcatExamplesUrl = "http://localhost:"+ sreePort + "/examples"
  end

  def webserver_name
    "tomcat"
  end

  def sreeHome
    SreeHome_tomcat
  end

  def sreePort
    return "7070" if  sreeHome =~/14/    
    ServerPort_tomcat
  end
  
  def stop_webserver
    puts "*** Stop tomcat server with sree app ..."
    begin
      services = `net help services`
      isUsingService = false
      services.each{|s| isUsingService = true if s =~ /apache tomcat/i}
      puts "isUsingService  = #{isUsingService }"
      if sreeHome !~ /14/
        puts "using net command to stop tomcat"
        `NET STOP "Apache Tomcat"`
      else
        puts "#{@sreeBatFileDir}\\StopTomcatServer.bat"

        %x["#{@sreeBatFileDir}\\StopTomcatServer.bat"]
      end

       wait_while(30) { ping(@sreeManagerUrl) =~/200|302/}
      $?
    rescue
     $!.to_s 
    end
  end
  alias :shutdown_sree :stop_webserver

  def start_webserver
    services = `net help services`
      isUsingService = false
      services.each{|s| isUsingService = true if s =~ /apache tomcat/i}      
      if sreeHome !~ /14/
        puts "using net command to start"
        t1 = Thread.new do
          `NET START "Apache Tomcat"`
        end
      else
        puts "*** Start tomcat server with sree app ..."
        t1 = Thread.new do
          system(@sreeBatFileDir + "\\StartTomcatServer.bat")
        end
      end
    
    wait_while(60) { ping(@sreeManagerUrl) !~/200|302/}
    $?
  end
  alias :start_sree :start_webserver

  def restart_webserver
    stop_webserver
    start_webserver
  end


  def redeploy_sree(appname="cc")    
    update_sree_web_services(webserver_name)

    shutdown_sree
    # todo:
    # delete sree folder
    start_sree
    shutdown_sree
    update_sree_properties(webserver_name, appname)
    start_sree
    # puts "*** Tomcat server up? --" # #{is_sree_up?("tomcat")}\n"

  end
  
end
