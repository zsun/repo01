# Created by IntelliJ IDEA.
# User: jimsun
# Date: Jul 29, 2008
# Time: 2:38:20 PM
# To change this template use File | Settings | File Templates.

require 'watir'
require 'ftools'
require 'fileutils'
require 'InetSoft'
require 'MyRubyUtil'
include MyRubyUtil     

=begin
  This script will deploy a new Inetsoft war to the Weblogic server.
  The assumptions are mainly defined in the variables located in the initialize function.
    1. The explode sree.war is located in c:\bea\jim\sree folder
    2. Weblogic port number is at 7001 which need to be a random port number if we want it to run on TH later
    3. Weblogic server is installed at C:\\bea\\wlserver_10.0
    4. The newly built sree.war file resides in   "C:\\depot\\eng\\bedrock\\active\\pl\\core\\sree-int\\cc\\dist"

    todo: is there a way to not show the WebLogic webcome page after server is started?
=end


class WeblogicHandler   < InetSoft
  attr_reader :batFileDir, :new_war_dir, :current_war_dir, :sree_app_location
  def initialize
    @weblogic_server_url = "http://localhost:7001"
    @weblogic_main_url = "#{@weblogic_server_url}/index.jsp"
    @weblogic_console_url = "#{@weblogic_server_url}/console"
    # @sreereporturl = "#{@weblogic_server_url}/sree"

    @batFileDir= "C:\\bea\\wlserver_10.0\\samples\\domains\\wl_server\\bin"
    @new_war_dir=current_branch_dir() +"sree-int\\cc\\dist"
    # @current_war_dir="C:\\bea\\tmp" # if deploying using the war file
    @current_war_dir="C:\\bea\\jim" # parent dir of the exploded war folder
    @sree_app_location = "C:\\bea\\wlserver_10.0\\samples\\domains\\wl_server\\servers\\examplesServer\\tmp\\_WL_user\\sree"

  end

  def webserver_name
    "weblogic"
  end

  def sreeHome
    SreeHome_weblogic
  end

  def set_war_locations  (current_war, new_war)
    @current_war_dir, @new_war_dir = current_war, new_war
  end

  def stop_webserver
    puts "*** stopping Weblogic server ..."
    system(@batFileDir+"\\stopWebLogic.cmd")
    $?
  end
  def start_webserver
    puts "*** starting Weblogic server ..."
    t1 = Thread.new do     
      system(@batFileDir+"\\startWebLogic.cmd")      
    end
    wait_while(90) { ping(@weblogic_main_url) != "200"}    
    $?
    puts "*** weblogic console: #{@weblogic_console_url}"
    
  end

  def find_sree_in_deplyment_list
    found=false
    3.downto(1) do
      (found=true; break)  if @new_ie.text.include?("sree")
      @new_ie.link(:text, "Next").click if !@new_ie.text.include?("sree") and @new_ie.link(:text, "Next").exists?
    end
    found
  end
  
  def go_to_deployments_page
    if @new_ie == nil
      @new_ie=Watir::IE.new_window()
    end
    
    puts "*** go to weblogic console: #{@weblogic_console_url}"
    @new_ie.goto(@weblogic_console_url)
    @new_ie.wait
    if !@new_ie.link(:id, "linkAppDeploymentsControlPage").exist?
      wait_while(30) { !@new_ie.text_field(:name, "j_username").exists? }
      @new_ie.text_field(:name, "j_username").set("weblogic")
      @new_ie.text_field(:name, "j_password").set("weblogic")
      @new_ie.button(:class, "formButton").click()

      wait_while(60) { !@new_ie.link(:id, "linkAppDeploymentsControlPage").exists? }
      @new_ie.button(:name, "save").click if @new_ie.button(:name, "save").exists? && @new_ie.button(:name, "save").enabled?
    end

    # click deployments link
    @new_ie.link(:id, "linkAppDeploymentsControlPage").click 

  end

  def stop_sree_app
    puts "*** stopping inetsoft app ..."
    go_to_deployments_page

    find_sree_in_deplyment_list

    if @new_ie.text.include?("sree")
      puts "*** stop sree first"
      @new_ie.checkbox(:id, "AppDeploymentsControlPortletchosenContents").set
      @new_ie.button(:name, "Stop").click
      @new_ie.link(:text, "Force Stop Now").click

      if @new_ie.text.include?("an incompatible state and will not be included in this operation")
        warning "issue to stop sree app, maybe it is stop already, let's move on to delete it"
      else
        @new_ie.button(:name, "Yes").click
      end
   else
     warning "Did not find sree application to stop!!" 
   end
  end

  def remove_inetsoft
    puts "*** remove_inetsoft ... "
    stop_sree_app

    puts "*** delete sree"
    go_to_deployments_page

    find_sree_in_deplyment_list

    if @new_ie.text.include?("sree")
      @new_ie.button(:name, "save").click if @new_ie.button(:name, "save").exists? && @new_ie.button(:name, "save").enabled?      
      @new_ie.checkbox(:id, "AppDeploymentsControlPortletchosenContents").set
      @new_ie.button(:name, "Delete").click
      @new_ie.button(:name, "Yes").click

      warning ("deleting sree app - Selected Deployments were deleted. Remember to click Activate Changes after you are finished") { @new_ie.text.include?("Selected Deployments were deleted. Remember to click Activate Changes after you are finished")}

      puts "*** activate the change"
      @new_ie.button(:name, "save").click
      if @new_ie.text.include?("All changes have been activated. No restarts are necessary")
        puts "*** app remove successfully, Weblogic does not need to be restarted"
      elsif @new_ie.text.include?("error")
        puts "*** Error: app remove failed!!"
      else
        puts "*** application removed successfully"
      end
    else
      warning "Did not find sree application to remove, maybe it is removed already or never deployed!!"
    end

  end

  def start_sree_app
    puts "*** starting up sree app ... "
    go_to_deployments_page

    find_sree_in_deplyment_list
    
    @new_ie.button(:name, "save").click if @new_ie.button(:name, "save").exists? && @new_ie.button(:name, "save").enabled?

    find_sree_in_deplyment_list
    
    @new_ie.checkbox(:id, "AppDeploymentsControlPortletchosenContents").set
    @new_ie.button(:name, "Start").click
    @new_ie.link(:text, "Servicing all requests").click
    @new_ie.button(:name, "Yes").click
    assert ("Error to start up the deployed sree app") {@new_ie.text.include?("Start requests have been sent to the selected Deployments")}    
    
  end

  def deploy_inetsoft
    puts "*** deploy_inetsoft app..."
    go_to_deployments_page
    
    @new_ie.button(:name, "save").click if @new_ie.button(:name, "save").exists? && @new_ie.button(:name, "save").enabled?

    @new_ie.button(:name, "Install").click

    puts "*** click on localhost node first"    
    @new_ie.link(:text, "localhost").click # start from root

    # version 1: to use the exploded sree folder to deploy
    if ( !@new_ie.link(:text, "sree").exists?)
      puts "*** will deploy using the exploded sree app"
      @current_war_dir.split('\\').each do |node|
        node += "\\" if node =~/:$/
        puts "*** click on node: #{node}"
        @new_ie.link(:text, node).click
      end
      assert("Error: did not find the sree.war to deploy!") {@new_ie.text.include?("sree")}
    end

    # version 2: to deploy using the sree.war
    #    if ( !@new_ie.text.include?("sree.war"))
    #      puts "*** will deploy using the sree.war"
    #      @current_war_dir.split('\\').each do |node|
    #        node += "\\" if node =~/:$/
    #        puts "*** click on node: #{node}"
    #        @new_ie.link(:text, node).click
    #      end
    #      assert("Error: did not find the sree.war!") {@new_ie.text.include?("sree.war")}
    #    end

    @new_ie.radios[1].set                       # select the sree folder for deployment
    @new_ie.button(:name, "Next").click 

    @new_ie.radios[1].set                       # Install this deployment as an application
    @new_ie.button(:name, "Next").click
    @new_ie.text_field(:name, "AppApplicationInstallPortletname").set("sree")
    @new_ie.radios[@new_ie.radios.length].set   #I will make the deployment accessible from the following location
    @new_ie.button(:name, "Next").click

    @new_ie.radios[@new_ie.radios.length].set   # No, I will review configuration later

    @new_ie.button(:name, "Finish").click

    puts "*** activate the sree app ..."
    @new_ie.button(:name, "save").click

    warning ("Warning: Weblogic does not need to be restarted") { @new_ie.text.include?("All changes have been activated. No restarts are necessary")}

    start_sree_app

  end    

  def clean_sree_app_folder
    FileUtils.remove_dir @sree_app_location if !Dir[@sree_app_location]
  end
  
  def get_sree_classes
    # todo: should be removed later, this is a workaround until InetSoft has the fix for WebLogic
    cmd = "jar xvf " + @current_war_dir+"\\sree.war"

    # todo: use the actual unzipped dir above
    classes_dir_source = "C:\\bea\\jim\\WEB-INF\\classes"
    random_sree_app_dir = Dir.entries(@sree_app_location).select{|x|x != "." && x != ".."}[0]

    classes_dir_target = @sree_app_location+"\\" +random_sree_app_dir  +"\\war\\WEB-INF\\classes"
    system("XCOPY #{classes_dir_source}\\* #{classes_dir_target} /s /i")
  end
 
  def get_new_sree_war
    # to copy the freshly built sree.war file to a location from which
    # it will be used for deployment if deploy from sree.war
    begin
      current_war = @current_war_dir+"\\sree.war"
      old_time = File.ctime(current_war)
      puts "*** old: sree.war: #{old_time}"
      File.delete(current_war) if File.exists?(current_war)

      build_sree_war

      new_war = @new_war_dir+"\\sree.war"
      assert("error: did not find the new sree.war file at: #{new_war}"){File.exists?(new_war)}
      File.copy(new_war, current_war)
      new_time = File.ctime(current_war)
      puts "*** new sree.war: #{new_time}"
      warning ("Warning: the sree.war file is the same as before!") { old_time.equal?(new_time)}
    rescue
      $?
    end
  end

  def restart_webserver
    stop_webserver
    start_webserver
  end

   def close_IE_openned_by_start
    require 'watir'
    begin
      4.downto(0) do
        port_hint = ":"+@weblogic_server_url.split(/:/)[2]
        puts "port_hint=#{port_hint}"
        @the_ie= Watir::IE.attach(:url, Regexp.new( port_hint ) )
        @the_ie.wait
        @the_ie.close
      end
    rescue

    end

   end
  
  def redeploy_sree(appname="cc")
    
    puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    puts "++++++++++++++ get rid of the existing sree app +++++++++++++++++++++++"
    puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    restart_webserver
    remove_inetsoft


    puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    puts "++++++++++++++ deploy the new sree app ++++++++++++++++++++++++++++++++"
    puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    stop_webserver
    clean_sree_app_folder
    get_new_sree_war

    start_webserver
    deploy_inetsoft

    puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    puts "++++++++++++++ update sree app config and restart weblogic ++++++++++++"
    puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    update_sree_web_services(webserver_name)
    update_sree_properties(webserver_name, appname)
    #get_sree_classes  # ?? a workaround if deploying using the sree.war file? not working so far, have to deploy using exploded folder 
    restart_webserver  # todo: maybe we can just restart sree app? looks like yes, otherwise the new cc port won't be picked up'
#    stop_sree_app
#    start_sree_app

    puts "*** Weblogic server up? -- #{is_sree_up?(webserver_name, @new_ie)}\n"
    
    close_IE_openned_by_start

  end
end


