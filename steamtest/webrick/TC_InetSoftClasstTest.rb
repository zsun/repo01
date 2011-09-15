# Created by IntelliJ IDEA.
# User: jimsun
# Date: Aug 5, 2008
# Time: 2:20:18 PM
# To change this template use File | Settings | File Templates.

require "MyRubyUtil"
include MyRubyUtil
require 'InetSoft'
require 'WatirHandler'
require 'WeblogicHandler'
require 'WebsphereHandler'
require 'TomcatHandler'
require 'test/unit'


class TC_InetSoftClasstTest < Test::Unit::TestCase
   def setup
     @testee = InetSoft.new

     @server_handlers = [
      # TomcatHandler.new, WebsphereHandler.new, WeblogicHandler.new
     TomcatHandler.new
     ]
   end

   def teardown

   end

    def test_files_in_place
      # test will make sure all the needed files/directories are in place
      @server_handlers.each do |server|

        puts("==========Testing for #{server.webserver_name} webserver =======================================================")
        begin
          assert(File.exists?($sree_webservice_dir), "Failed to find #{$sree_webservice_dir}")
        rescue
        end

        # should be tested after the deployment
        #assert(File.exists?(server.sree_properties_path(server.webserver_name)), "Failed to find sree.properties file")
        puts "server.sreeHome to use = #{server.sreeHome}"
        # assert(File.exists?(server.sreeHome), "Failed to find SreeHome for #{server.webserver_name}")

        case server.webserver_name
              when /weblogic/i
                assert(File.exists?(server.batFileDir), "Failed to find the bat file dir for starting/stopping weblogic webserver")
                # need to assert after the war is built
                #assert(File.exists?(server.new_war_dir), "Failed to find the new_war_dir where sree.war should be built into")
                assert(File.exists?(server.current_war_dir), "Failed to find the current_war_dir where sree.war to be used from")
                # should be tested after the deployment
                # assert(File.exists?(server.sree_app_location), "Failed to find the dir where sree should be deployed into")          
              when /websphere/i
                assert(File.exists?(server.websphere_server_home_dir), "Failed to find Websphere webserver home directory")
                assert(File.exists?(server.Websphere_server_bin_dir), "Failed to find Websphere webserver bin directory")
                assert(File.exists?(server.sree_war_file), "Failed to find the sree.war for Websphere webserver")
                
        when /tomcat/i
                puts "Dir.pwd = #{Dir.pwd}"
                puts "server.sreeBatFileDir =#{server.sreeBatFileDir}"
                assert(File.exists?(server.sreeBatFileDir + "\\StartTomcatServer.bat"), "Failed to find #{server.sreeBatFileDir + "\\StartTomcatServer.bat"}")
                assert(File.exists?(server.sreeBatFileDir + "\\StopTomcatServer.bat"), "Failed to find #{server.sreeBatFileDir + "\\StopTomcatServer.bat"}")
                assert(File.exists?(server.sreeHome), "Failed to find TomCat home directory")
              else
                # invalid webserver
            end
      end

    end

    def test_get_webserver_port_for
      @server_handlers.each do |server|
        case server.webserver_name
        when /tomcast/i
           assert(@testee.get_webserver_ port_for("tomcat")==server.sreePort, "Webserver port number for tomcat")
        when /websphere/i
          assert(@testee.get_webserver_port_for("websphere")==server.ServerPort_websphere, "Webserver port number for websphere")
        when /weblogic/i
          assert(@testee.get_webserver_port_for("weblogic")==server.ServerPort_weblogic, "Webserver port number for weblogic")
        else
          #
        end
          # special case for websphere
          assert(@testee.get_webserver_port_for("websphere", true)=="9060", "Webserver Admin port number for websphere")
      end
      

    end

   def test_update_sree_properties
     # sree_home:
     # C:\bea\jim\sree\WEB-INF\classes\sree.properties
     # C:\Program Files (x86)\IBM\WebSphere\AppServer\profiles\AppSrv01\installedApps\KAIHUNode01Cell\sree_war.ear\sree.war\WEB-INF\classes\sree.properties
     # c:\apache-tomcat-6.0.14\webapps\sree\WEB-INF\classes\sree.properties

     # Note, should only run after the deployment, otherwise, there is no sree.properties in the webservers
     @server_handlers.each do |server|
       passed=false
       begin
         puts("==========Testing for #{server.webserver_name} webserver =======================================================")
         found_license = false
         found_gw_url = false

         location_of_datasource_xml=""

         gw_serverAndPort = "localhost" # :xxxx" # use "localhost:8080" for standalone CC server
        
         server.update_sree_properties(server.webserver_name)
         sreePropertiesFile = server.sree_properties_path(server.webserver_name)
         puts "sreePropertiesFile = #{sreePropertiesFile}"
         
         #open($temp_serverurl_file) { |f| serverAndPort = f.read }
         open(sreePropertiesFile).each { |line|
           found_license = true if line =~ /license.key=C000-6F2-ERX-000097001000006-F29103071765\n/
           found_gw_url = true if line =~ /gw\.url=http:/ and line =~ Regexp.new(gw_serverAndPort)
           location_of_datasource_xml=line.split(/=/)[1] if line =~ /datasource\.registry\.file/ 
         }
         assert(found_license, "License.key was not updated properly for #{server.webserver_name} in file: #{sreePropertiesFile}")
         assert(found_gw_url , "gw.url was not updated properly for #{server.webserver_name} in file: #{sreePropertiesFile}")

         # to check if the datasource.xml file is in the right location
         # e.g. datasource.registry.file=$(sree.home)/sql/datasource.xml
         sree_home=sreePropertiesFile.sub("\\sree.properties", "")
         puts "sree_home=#{sree_home}"
         location_of_datasource_xml=location_of_datasource_xml.gsub("/", "\\").sub("$(sree.home)", sree_home).chomp
         puts "location_of_datasource_xml = #{location_of_datasource_xml}"
         puts File.size?(location_of_datasource_xml)

         assert(File.exist?(location_of_datasource_xml) , "datasource.xml not found at #{location_of_datasource_xml}")
         assert(File.size?(location_of_datasource_xml)>100 , "Did not have enough content: #{location_of_datasource_xml}")

         #require 'rexml/document'
         # include REXML
         #doc = Document.new(File.new(location_of_datasource_xml))
         #root = doc.root
         #puts root.elements["biblioentry[1]/author"]
         #puts root.elements["biblioentry[@id='FHIW13C-1260']"]

         #puts root.elements["datasource[1]/ds_jdbc"]
         
         passed=true
       rescue
         puts $!
       end
       raise "sreePropertiesFile check failed for #{server.webserver_name}" if !passed

       # expected result: 1 tests, 12 assertions, 0 failures, 0 errors
       
     end
   end

   def test_update_sree_web_services

     @server_handlers.each do |server|
       puts("==========Testing for #{server.webserver_name} webserver =======================================================")
       found_port = false
       server.update_sree_web_services(server.webserver_name)

       web_service_files = ["sree.wsdl", "sree.xml"]
       webserver_port = server.webserver_port(server.webserver_name)

       web_service_files.each {|file|
          open($sree_webservice_dir+"\\"+ file).each { |line|
            (found_port=true; break) if line =~ Regexp.new(":#{webserver_port}\/sree")
          }
          assert(found_port , "found_port was not found in #{file}")
        }
     end
   end


end








