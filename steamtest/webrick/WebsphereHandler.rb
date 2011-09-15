# Created by IntelliJ IDEA.
# User: jimsun
# Date: Aug 2, 2008
# Time: 2:07:50 PM
# To change this template use File | Settings | File Templates.


require 'MyRubyUtil'
require 'InetSoft'

class WebsphereHandler  < InetSoft

  attr_reader :websphere_server_home_dir, :Websphere_server_bin_dir, :sree_war_file
  def initialize
    @websphere_server_home_dir = "C:\\Program Files (x86)\\IBM\\WebSphere\\AppServer\\profiles\\AppSrv01"
    # @websphere_server_home_dir = 'C:\Program Files (x86)\IBM\WebSphere\AppServer'

    @Websphere_server_bin_dir ="#{@websphere_server_home_dir}\\bin\\"
    @logfile = "#{@websphere_server_home_dir}\\logs\\server1\\stopServer.log"
    @sree_war_file = 'C:\bea\sree.war'
    @websphereconsole_url="http://localhost:9060/ibm/console/"
  end

  def webserver_name
    "websphere"
  end

  def sreeHome
    SreeHome_websphere
  end

  def shutdown_sree
    puts "*** Stop web server with sree app ..."
    
  end

  def start_sree
    puts "*** Start web server with sree app ..."

  end



  def enable_visual_envion_component
      # todo-jimsun   ??
      #      1.   Start WebSphere and open the administration console.
      #      2.   Navigate to the following location:
      #      Servers ? Application Servers ? server1 ? Process Definition ? Java Virtual Machine ? Custom Properties
      #      3.   Create a new custom property:
      #      Name: java.awt.headless
      #      Value: true
      #      Description: Setting to allow Guidewire Standard Reporting to work within WebSphere
      #      4.   Restart the WebSphere server. The change does not go into effect until you restart the server.
  end
  def deploy_inetsoft

      IeLauncher.open(@websphereconsole_url) do |ie|

        ie.button(:value, 'Log in').click

        if ie.contains_text('Login Conflict')
          ie.radio(:name, 'action', 'force').set
          ie.button(:value, 'OK').click
        end
        if ie.contains_text('Another user is currently logged in with the same user ID')
          ie.radio(:id, 'forceradio').set
          ie.button(:value, /OK/).click
        end
        
        if ie.contains_text('Recover prior changes')
          ie.radios[2].set     # recover from last time
          ie.button(:value, /OK/).click
        end

        navigation = ie.frame('navigation')
        navigation.link(:text, 'Applications').click
        navigation.link(:text, 'Enterprise Applications').click
        detail_frame = ie.frame('detail')

        # Uninstall the existing sree
        if detail_frame.contains_text('sree')
          dukesbank_checkbox = detail_frame.checkbox(:value, /sree/)
          dukesbank_checkbox.click
          detail_frame.button(:value, 'Uninstall').click
          detail_frame.button(:value, 'OK').click

          detail_frame.link(:text, 'Save').click
          assert("sree application still exists") { not detail_frame.link(:text, 'sree').exists?  }
        else
          puts "No sree application was previously installed"
        end

        # Install  sree
        detail_frame.button(:value, 'Install').click

        detail_frame.radio(:id, 'local').click
        
        detail_frame.file_field(:name, 'localFilepath').set(@sree_war_file)

        detail_frame.text_field(:name, 'contextRoot').set('sree')
        
        button = detail_frame.button(:value, 'Next')
        while button.exists?
          if  (ie.contains_text('Select installation options') && detail_frame.text_field(:id, '6').exist? ) # && detail_frame.text_field(:id, '6').exist?)
             detail_frame.text_field(:id, '6').set('sree')

          end
          button.click
          begin
            puts detail_frame.text
          rescue => detail
            puts "*** Todo: sometimes, we have to restart computer to clear up the 500 error, why?"
            print detail.backtrace.join("\n")
            #sleep 300
          end
          button = detail_frame.button(:value, 'Next')
        end

        detail_frame.button(:value, 'Finish').click     
        detail_frame.link(:text, 'Save').click

      end
  end

   def stop_webserver
    puts "Stopping Websphere server1 ..."
    cmd = "StopWebsphereServer.bat"
    puts `"#{cmd}"`
  end

  def start_webserver
    puts "Starting Websphere server1 ..."
    cmd = "StartWebsphereServer.bat"
    puts "cmd = #{cmd}"
    output = `"#{cmd}"`
    puts output

    puts "Websphere log file: " + @logfile
    puts "Websphere admin console url: #{@websphereconsole_url}"
  end

  def restart_webserver
    stop_webserver
    start_webserver
  end

 
  
  def redeploy_sree(appname="cc")

        puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        puts "++++++++++++++ deploy the new sree app ++++++++++++++++++++++++++++++++"
        puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

        restart_webserver
        deploy_inetsoft

        puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        puts "++++++++++++++ update sree app config and restart websphere ++++++++++++"
        puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        update_sree_web_services(webserver_name)
        update_sree_properties(webserver_name, appname)

        restart_webserver

        puts "*** Is sree running in #{webserver_name}? -- #{is_sree_up?(webserver_name, @new_ie)}\n"


  end
end