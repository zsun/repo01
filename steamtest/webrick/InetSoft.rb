# Created by IntelliJ IDEA.
# User: jimsun
# Date: Jul 31, 2008
# Time: 1:58:53 PM
# To change this template use File | Settings | File Templates.


=begin
    Generic IneetSoft report server manipulation routines
=end
require 'watir'
require 'MyRubyUtil'
require 'Handler'
require 'SteamConfig'
include SteamConfig

class InetSoft  <  Handler

  include MyRubyUtil
  # todo: move these server specific stuff into the correcponding classes   
  $gw_server_host_and_url = "not_set"
  $sree_webservice_dir = current_branch_dir() +"\\platform\\pl\\config\\webservices"
  $app_name = "no_set"

  def handle(parameters={})
    command = !parameters.empty? && parameters.has_key?("command") ? parameters["command"] : nil
    $gw_server_host_and_url = !parameters.empty? && parameters.has_key?("gw_server_host_and_port") ? parameters["gw_server_host_and_port"] : "not_set"
    $app_name = !parameters.empty? && parameters.has_key?("app_name") ? parameters["app_name"] : "cc"
    
    puts "handler was asked to do: #{command} ..."
    command.downcase!
    unless parameters.empty?
       case command
       when /redeploysree/i
            # $gw_server_host_and_url=parameters["gw_server_host_and_port"] # if parameters.has_key?("gw_server_url_and_port")
            puts "the server host and url is: #{$gw_server_host_and_url}" 
            redeploy_sree($app_name)
             "ok, sree server relaunched in webserver!\n"
          when /shutdownsree/i
            shutdown_sree
         when "restart_webserver"
            restart_webserver
         when "start_webserver"
            restart_webserver
         when "stop_webserver"
            stop_webserver
          else
            "Warning - command not supported - #{command}"
        end
    end
  end
  
  def get_webserver_port_for(webserver, bGetAdminPort=false)      
       case webserver
          when /weblogic/i
            server_port=ServerPort_weblogic
          when /websphere/i
            server_port=ServerPort_websphere
            server_port=ServerAdminPort_websphere if bGetAdminPort
          else  # "tomcat"
            server_port=ServerPort_tomcat
        end
    puts "*** get port to be: #{server_port} for server type of #{webserver}"
    server_port
  end

  def self.get_webserver_port_for(webserver, bGetAdminPort=false)
      InetSoft.new.get_webserver_port_for(webserver, bGetAdminPort)       
  end

  def valid_webserver? (webserver)    
    return true if webserver /tomcat|weblogic|websphere/i
    false
  end

  def sree_url_for  (webserver, serverhost="localhost")
    "http://"+ serverhost+ ":" + get_webserver_port_for(webserver) + "/sree"         
  end

  def sree_properties_path  (server_type = "tomcat")
    if server_type =~/websphere/
      sreeHome = SreeHome_websphere
       sreePropertiesFile =sreeHome + "\\WEB-INF\\classes\\sree.properties"
    elsif  server_type =~/tomcat/
      sreeHome = SreeHome_tomcat
       sreePropertiesFile =sreeHome + "\\sree\\WEB-INF\\classes\\sree.properties"
    elsif server_type =~/wlserver|weblogic/
       sreeHome = SreeHome_weblogic
       sreePropertiesFile =sreeHome + "\\sree\\WEB-INF\\classes\\sree.properties"
    else
      puts "Error: don't know what kind of server you are asking!"
    end
    sreePropertiesFile
  end
  
  def update_sree_properties (server_type="tomcat", appname="cc")
    puts "update_sree_properties for webserver: #{server_type}..."
    sreePropertiesFile =  sree_properties_path(server_type)
    
    serverAndPort = "localhost:xxxx" # use "localhost:8080" for standalone CC server        
    
    serverAndPort= $gw_server_host_and_url
    if serverAndPort =~ /not_set|dev_mode/
      puts "*** Warning: serverAndPort not passed in from smoketest? let's use the CC's default value: localhost:8080"
      serverAndPort = "localhost:8080"
    end
    
    puts "*** Configure sree.properties with  CC serverAndPort: "+serverAndPort
    puts "sree.properties: " + sreePropertiesFile
    properties ||= []
    open(sreePropertiesFile).each { |line|
      line = "license.key=C000-6F2-ERX-000097001000006-F29103071765\n" if line =~ /license\.key=/
      line = "gw.url=http://"+ serverAndPort + "/"+ appname+ "/soap/ISREEAuthenticationAPI\n" if line =~ /gw\.url=/
      line = "html.showreplet.window=false\n" if line =~ /html\.showreplet\.window=/
     
      # update the datasource.xml location
      properties << line
    }
    open(sreePropertiesFile, 'w') { |f| f <<  properties  }

  end

  #todo update config-override.xml for report url setting in
  #p4\depot\eng\pl\carbon\active\af2\app-cc\cc-test\gtest\gw\smoketest\cc\report\inetSoft_tomcat_Config\config
  # <param name="StyleReportURL" value="http://localhost:7070/sree"/>
  # can use one IncludeModules for all app servers
  
  def update_sree_web_services (webserver)

    # might not be needed if this can be done inside smoketest script
    # see CC-42309 Need a method to update webservice files against InetSoft report server
    
    puts "*** prepare the web service files against #{webserver} for GW apps (cc, bc, pc) ..."
    web_service_files = ["sree.wsdl", "sree.xml"]
    webserver_port = get_webserver_port_for(webserver)
    puts "*** the sree port number to be used by the GW app webservice is #{webserver_port}"    
    
    web_service_files.each {|file|
      fn=$sree_webservice_dir+"\\"+ file
      puts "Updating CC webservice file: "+fn
      lines=""
      `p4 edit #{fn}`
      open(fn).each { |line|
        lines << line.gsub(/:\d{3,}\/sree/, ":" + webserver_port +"\/sree")        
      }
      open(fn, 'w') { |f| f <<  lines  }
    }

  end

  def is_sree_up?(webserver="tomcat", the_ie=nil)
    running = false
    close_ie = false
    (close_ie = true; the_ie=Watir::IE.new_window() ) if the_ie == nil    
    the_ie.goto( sree_url_for(webserver) )
    puts "*** checking if SREE up running in the webserver of #{webserver} at #{sree_url_for(webserver) }"
    the_ie.wait

    running = true if the_ie.text.include?("InetSoft Examples Home")
    puts "*** closing the IE browser used for checking whether sree up running ... "
    the_ie.close if close_ie    
    begin
      3.downto(1) do |i|
        weblogic_welcome_page = Watir::IE.attach(:title, /welcome to bea weblogic|inetsoft examples/i  )
        weblogic_welcome_page.wait
        weblogic_welcome_page.close
      end
    rescue
      $?
    end
    puts ("running = #{running}")
    running
  end

  def webserver_port (webserver)
    get_webserver_port_for(webserver)
  end

  def is_webserver_up? (webserver)
          
          @running = false
          @webserver_admin_url = ""
          begin

            case webserver
              when /weblogic/i
                @hint = "Welcome to BEA WebLogic Server"
                @webserver_admin_url = "http://localhost:" + webserver_port(webserver)
              when /websphere/i
                @hint = "Welcome, enter your information"                                
                @webserver_admin_url = "http://localhost:" + ServerAdminPort_websphere+ "/ibm/console/"
              when /tomcat/i                
                @hint = "Apache Tomcat Examples"
                @webserver_admin_url = "http://localhost:" + webserver_port(webserver)  + "/examples/"
              else
                @hint = "wrong server type"
            end
            puts "webserver_url =#{@webserver_admin_url}"
            puts "hint= #{@hint}"
            
            new_ie=Watir::IE.new_window()
            puts "Go to #{@webserver_admin_url}"
            new_ie.goto(@webserver_admin_url)
            new_ie.wait

            # puts "ie.text: "+  new_ie.text           

            @running = true if  (new_ie.text.include?(@hint))
            new_ie.close
          rescue
            puts  $!.to_s
            new_ie.close if new_ie.exist?
          end          
          puts "webserver running: #{@running}" if @running          
          @running
  end

  def rebuildSreeWar
    puts "### to be implemented" # todo
    raise NotImpelemntedError("#{self.class.name}#m1() is not implemented.")

  end
  # methods that need to be implemented it subclasse
  def webserver_name
    raise NotImpelemntedError("#{self.class.name}#m1() is not implemented.")
  end

  def sreeHome
    raise NotImpelemntedError("#{self.class.name}#m1() is not implemented.")
  end

  def redeploy_sree (appname)
    raise NotImpelemntedError("#{self.class.name}#m1() is not implemented.")    
  end

  def stop_webserver
    raise NotImpelemntedError("#{self.class.name}#m1() is not implemented.")
  end

  def start_webserver
    raise NotImpelemntedError("#{self.class.name}#m1() is not implemented.")
  end

  def restart_webserver
    raise NotImpelemntedError("#{self.class.name}#m1() is not implemented.")    
  end

end
