# Created by IntelliJ IDEA.
# User: jimsun
# Date: Jul 25, 2008
# Time: 10:00:38 AM
# To change this template use File | Settings | File Templates.


require 'watir'
require 'MyRubyUtil'
require 'InetSoft'
require 'timeout'
require 'TomcatHandler'

class WatirHandler  < InetSoft

  def initialize
    #
  end
  
  include MyRubyUtil
  include IE_popup
    
  def handle(parameters={})    
    command = !parameters.empty? && parameters.has_key?("command") ? parameters["command"] : nil
    puts "handler was asked to do: #{command} ..."
    $gw_server_host_and_url = !parameters.empty? && parameters.has_key?("gw_server_host_and_port") ? parameters["gw_server_host_and_port"] : "not_set"
    
    unless parameters.empty?
       case command
       when /createinetsoftreport/i
         open_inetsoft_portal()
         # sleep 3600
         create_inetsoft_report(parameters)
       when /sree_portal_login/i
         sree_portal_login(parameters)
       when /create_report_folder/i
         create_report_folder(parameters)
       when /closeHtmlDocWithTitle/i     # for doc testing
          closeHtmlDocWithTitle(parameters)
       when /viewHtmlDocContent/i        # for doc testing
           viewHtmlDocContent(parameters)
       when /pick_calendar_date/i        # for calender manipulation
           pick_calendar_date(parameters)
       when /screenshot/i        
           screenshot(parameters)
       else
            "Warning - command not supported - #{command}"
       end
    end
  end

  def open_inetsoft_portal ()
    result="### error to do #{this_method}"
    begin
      puts "Warning, the Watir version in use should be 1.5.3.x and above!!!"
      # puts "Your Watir version:   #{Watir::IE::VERSION}"

      
      @gw_serverAndPort = $gw_server_host_and_url
      return "Host name and port number do not get passed in" if @gw_serverAndPort=="not_set"
      @existing_ie= Watir::IE.attach(:url, Regexp.new(":"+@gw_serverAndPort.split(/:/)[1])   )
      puts "did not find ie with BC" if not @existing_ie
      puts "@existing_ie.url = " + @existing_ie.url
      puts "### The target GW app server and port: "+@gw_serverAndPort
      
      @existing_ie.wait
      @sreestuff=@existing_ie.frame(:name, "selenium_myiframe").frame(:name, "top_frame").div(:id, "SreeReportPage").html
      @sreestuff =~ /inetframe src=\"(.*)\" width=/
      sreereporturl=$1.gsub!(/&amp;/, '&')
      puts "### sreereporturl to go to = "+sreereporturl
      oldurl=@existing_ie.url
      puts "### oldurl: "+ oldurl
      @new_ie=Watir::IE.new_window()
      @new_ie.goto(sreereporturl)
      wait_while (30) { !@new_ie.text.include?("Report") }
      puts "### Report is open in InetSoft Portal"
     webserver= !queries.empty? && queries.has_key?("webserver") ? queries["webserver"] : "tomcat"
     puts "*** will use the default values to create report" if queries.empty?
    rescue
      result += "### Error: problem to #{this_method}: "+$!.to_s
    end
  end

  def create_inetsoft_report (queries = {} )
    result="### error to do #{this_method}"
    
    
    # puts "Turn on the following line to look for InetSoft dropdown or textfield names"
    puts "the textfields:"
    @new_ie.text_fields.each { |t| puts t.to_s }   
    puts "the dropdowns:"
    @new_ie.select_lists.each { |t| puts t.to_s }  
   
    begin
      queries.each {|key, value|
              
              
              column_name = key.gsub("_", "")
              column_name = column_name.gsub(" ", "")
	      puts "*** Working on query: #{key} : #{value}"
	      puts "column_name = #{column_name}"
	      continue if key =~ /createinet/ or key =~ /tomcat/ or key =~ /watir/i # or key =~ /:/
	      begin
		   case column_name	      
		      when "adjuster"
			puts "### select activity owner Applegate, Andy"
			@new_ie.select_list(:name, "Adjuster").select(value)
		      when /xxx/ # group ??
		      # todo: implement to pick group	      
		      when /xxx/ # time
		      # todo: implement to pick a time
		      when /report*date/i
			@new_ie.select_list(:name, column_name).select(value)	
	              when /account*number/i 
			puts "1 setting account number"
			@new_ie.text_field(:name, column_name).set(value)		      		      	      
		      else
			begin
			   print "using the default case to handle: #{column_name} ..."
			   @new_ie.select_list(:name, column_name).select(value) if @new_ie.select_list(:name, column_name).exists? 			  
			   @new_ie.text_field(:name, column_name).set(value) if @new_ie.text_field(:name, column_name).exists?    
			end
	           end
	      rescue
		    result+= "error to set value for " + key
	      end
     
              #sleep 3
      
      }      
      if @new_ie.button(:name, "Button4").exists?
        puts "### clicking the OK button(Button4) ..."
        @new_ie.button(:name, "Button4").click

        elsif
          @new_ie.button(:name, "Button5").exists?
          puts "### clicking the OK button(Button5) ..."
          @new_ie.button(:name, "Button5").click

        elsif
          @new_ie.button(:name, "Button14").exists?
          puts "### clicking the OK button(Button14) ..."
          @new_ie.button(:name, "Button14").click

        elsif
          @new_ie.button(:name, "OkButton2").exists?
          puts "### clicking the OK button(OkButton2) ..."
          @new_ie.button(:name, "OkButton2").click
       elsif  # the ok button for BC
	  @new_ie.button(:name, "Button3").exists?
	  puts "### clicking the OK button(Button3) ..."
          @new_ie.button(:name, "Button3").click          
        else
          puts "error: did not find the ok button"
       end

      puts "### wait for the result table ..."
      report_id_hint =  "Report" # "Report Description"
      wait_while (60) { !@new_ie.text.include?(report_id_hint) }
      puts "### Error: did not see the SREE report tables" if !@new_ie.text.include?(report_id_hint)

      drilldownname= !queries.empty? && queries.has_key?("drilldownname") ? queries["drilldownname"] : nil
      drilldownlink= !queries.empty? && queries.has_key?("drilldownlink") ? queries["drilldownlink"] : nil
      drilldownpagetitle= !queries.empty? && queries.has_key?("drilldownpagetitle") ? queries["drilldownpagetitle"] : nil
      puts "before regular expression, @sreestuff = #{@sreestuff}"

      if drilldownname
        puts   drilldownname
        begin
          puts "### click on drilldown link"
          @new_ie.link(:text, drilldownlink).click
          sleep 10
          @new_ie1= Watir::IE.attach(:title, drilldownpagetitle)
          wait_while (60) { !@new_ie1.text.include?(drilldownname) }
          puts "### Error: did not see the SREE report tables" if !@new_ie1.text.include?(drilldownname)
          puts "### getting the drilldown report table contents ... "


          puts "### getting the drilldown report table contents ... "
          @new_ie1.frame(:id, "reportiframe").tables.each { |d|
             if d.text.include?(drilldownname)
               result= d.text
               break
             end
          }
          @new_ie1.close
          @new_ie.close
        rescue
          result += "### Error: problem to #{this_method}: "+$!.to_s
        end

        else
          puts "### getting the report table contents ... "
          @new_ie.tables.each { |d|
             if d.text.include?(report_id_hint)
               result= d.text
               break
             end
      }

        @new_ie.close
    end

    rescue
      result += "### Error: problem to #{this_method}: "+$!.to_s
      begin
        @new_ie1.close if @new_ie1.exist?
        rescue
      end
      begin
        @new_ie.close if @new_ie.exist?
        rescue
      end
    end
    puts result
    result
  end
  
  def sree_portal_login(queries = {})
    # default values for the parameter
    username="su"
    password="gw"
    permission=false
     
    result="### error to do #{this_method}"
    begin
      queries.each {|key, value|
        case key
        when /permission/i
          permission=true if value =~/yes|true/i
        when /username/i
          username=value
        when /password/i
          password=value
        end
        }

      puts " open inetsoft report portal"
      @new_ie=Watir::IE.new_window()
      @new_ie.goto( sree_url_for("tomcat")+"/Examples" )
      @new_ie.wait

      wait_while (30) { !@new_ie.text.include?("User") }
      
      @new_ie.text_field(:name, "userid0").set(username)
      @new_ie.text_field(:name, "password0").set(password)

        if permission
          @new_ie.button(:name, "action").click
        
          wait_while (30) { !@new_ie.text.include?("Logout") }
          puts "### Error: do not find Logout link" if !@new_ie.text.include?("Logout")
          result = @new_ie.text
          @new_ie.link(:text, "Logout").click # if @new_ie.text.include?("Logout")
          @new_ie.close

        else
          @new_ie.button(:name, "action").click_no_wait
          popupChecker(@new_ie, "OK")

          wait_while (30) { !@new_ie.text.include?("Login") }
          puts "### Error: do not find Logout link" if !@new_ie.text.include?("Login")
          result = @new_ie.text
          @new_ie.close
        end

        rescue
          result = "### Error: problem to #{this_method}: "+$!.to_s
          @new_ie.close if @new_ie.exist?
      end
      puts result
      result
  end

  # report need to be configured with en_US, fr_CA and ja_JP locales
  # CC-43803
  def create_report_folder(server_type="tomcat")
    result=""
    sreeHome_tomcat = SreeHome_tomcat

    begin
      filename = sreeHome_tomcat + '\sree\WEB-INF\classes\repository.xml'
      filerename = sreeHome_tomcat + '\sree\WEB-INF\classes\repository.bak'

      filename_jajp = sreeHome_tomcat + '\sree\WEB-INF\classes\repository_ja_JP.xml'
      filerename_jajp = sreeHome_tomcat + '\sree\WEB-INF\classes\repository_ja_JP.bak'
    
      puts  sreeHome_tomcat
      puts "repository_jajp.xml size before folder update"
      fs1= File.size?(filename_jajp)
      puts fs1

      # default values for the parameter
      username="su"
      password="gw"

      puts " open inetsoft report portal"
      @new_ie=Watir::IE.new_window()
      @new_ie.goto( sree_url_for(server_type)+"/EnterpriseManager" )
      @new_ie.wait

      wait_while (30) { !@new_ie.text.include?("Administrator:") }

      @new_ie.text_field(:name, "admin").set(username)
      @new_ie.text_field(:name, "passwd").set(password)

      @new_ie.button(:value, "Login").click
      wait_while (30) { !@new_ie.text.include?("Logout") }
      puts "### Error: do not find Logout link" if !@new_ie.text.include?("Logout")

      wait_while (30) { !@new_ie.div(:id, "tabs").div(:class, "isii_JSTabbedPanel").span(:text, "Report").exist?}
      @new_ie.div(:id, "tabs").div(:class, "isii_JSTabbedPanel").span(:text, "Report").click

      wait_while (30) { !@new_ie.frame(:src, "/sree/EnterpriseManager?op=repletregistry_reportsTab").text.include?("Repository") }
      puts "### Error: did not see the SREE Repository tree" if !@new_ie.frame(:src, "/sree/EnterpriseManager?op=repletregistry_reportsTab").text.include?("Repository")

      # todo: implement to click icon to expend report tree

      @new_ie.frame(:src, "/sree/EnterpriseManager?op=repletregistry_reportsTab").frame(:id, "treeFrame").div(:class, "JSTreeLabel").click
      sleep 5

      wait_while (30) { !@new_ie.frame(:src, "/sree/EnterpriseManager?op=repletregistry_reportsTab").frame(:id, "treeFrame").button(:id, "newFolderBtn").enabled?}
      puts "### Error: New Folder link is not enabled" if !@new_ie.frame(:src, "/sree/EnterpriseManager?op=repletregistry_reportsTab").frame(:id, "treeFrame").button(:id, "newFolderBtn").enabled?

      @new_ie.frame(:src, "/sree/EnterpriseManager?op=repletregistry_reportsTab").frame(:id, "treeFrame").button(:id, "newFolderBtn").click
      sleep 5

      # todo: implement to enter report folder name and parent folder

=begin
      @new_ie.frame(:src, "/sree/EnterpriseManager?op=repletregistry_reportsTab").frame(:id, "propFrame").frame(:src, "/sree/EnterpriseManager?op=repletregistry_folder&action=showProperty&folder=Folder1&user=").text_field(:id, "name").set("TestFolderOne")
      @new_ie.frame(:src, "/sree/EnterpriseManager?op=repletregistry_reportsTab").frame(:id, "propFrame").frame(:src, "/sree/EnterpriseManager?op=repletregistry_folder&action=showProperty&folder=Folder1&user=").select_list(:id, "pFolder").select_value("ClaimCenter")
      @new_ie.frame(:src, "/sree/EnterpriseManager?op=repletregistry_reportsTab").frame(:id, "propFrame").frame(:src, "/sree/EnterpriseManager?op=repletregistry_folder&action=showProperty&folder=Folder4&user=").button(:id, "applyBtn1").click
      sleep 20
      @new_ie.frame(:src, "/sree/EnterpriseManager?op=repletregistry_reportsTab").frame(:id, "treeFrame").button(:id, "deleteBtn").click_no_wait
      popupChecker(@new_ie, "OK")
      @new_ie.close
=end

      puts "repository_ja_JP.xml size after folder update"
      fs2= File.size?(filename_jajp)
      puts fs2

      if fs1==fs2
        result += "CC-43803 is fixed"
      else
        result += "CC-43803 is not fixed"
      end

      @new_ie.close if @new_ie.exist?
=begin

      # todo: implement to remove newly created folder from EM UI
      # workaround to remove the updated repository.xml and rename repository.bak to repository.xml
      # The step will run when the jira is fixed
      File.delete(filename)
      if File.exist?(filename)
        puts "File #{filename} already exists.  Not renaming"
      else
        puts "   renaming #{filerename} to #{filename}"
        File.rename(filerename, filename)
=end
      # workaround to remove the updated repository_ja_JP.xml and rename repository_ja_JP.bak to repository_ja_JP.xml
      File.delete(filename_jajp)
      sleep 10
      if File.exist?(filename_jajp)
        puts "File #{filename_jajp} already exists.  Not renaming"
      else
        puts "   renaming #{filerename_jajp} to #{filename_jajp}"
        File.rename(filerename_jajp, filename_jajp)
      end
    rescue
      result += "### Error: problem to #{this_method}: "+$!.to_s
      @new_ie.close if @new_ie.exist?
    end
    puts result
    result
  end

  def closeHtmlDocWithTitle (queries = {} )
     result="### error to do #{this_method}"

     html_title_hint=""
     begin
         queries.each {|key, value|
         puts "*** Looking at query: #{key} : #{value}"
         case key
           when "title"
              html_title_hint=value
           else
         end
         }

         puts "### find and check content of the target browser page"
         sleep 10
         new_ie= Watir::IE.attach(:title, Regexp.new(html_title_hint))
         result= new_ie.text
         new_ie.close
     rescue
         result += "### Error: problem to #{this_method}: "+$!.to_s
     end
     result
  end

  def pick_calendar_date (queries = {} )
     result="### error to do #{this_method}"
     begin
         day_to_pick = ""
         calendarpicker="0" # default
         queries.each {|key, value|
           puts "*** Looking at query: #{key} : #{value}"
           case key
             when "day"
                day_to_pick=value
             when "calendarpicker"
                calendarpicker=value                 
             else
           end
           }
         url_hint = "\/selenium-server"
         result= "click to pick a day of #{day_to_pick}..."
         puts result
         sleep 2
         new_ie= Watir::IE.attach(:url, Regexp.new(url_hint))
         top_frame=new_ie.frame(:name, "selenium_myiframe").frame(:name, "top_frame")

         top_frame.image(:id, "calendarPicker#{calendarpicker}").click
         sleep 1
         top_frame.link(:text, day_to_pick).click

     rescue
         result += "### Error: problem to #{this_method}: "+$!.to_s
     end
     result
  end
  #for now, they both close the html page and return the content
  def viewHtmlDocContent (queries = {} )
      closeHtmlDocWithTitle (queries  )                
  end

  def screenshot (queries = {} )
     result="### error to do #{this_method}"

     filename="screenshot.png"
     folder="c:\\tmp"
     begin
         queries.each {|key, value|
         puts "*** Looking at query: #{key} : #{value}"
         case key
           when /file/i
              filename=value
              filename=filename + ".png" if  filename !~ /\.png$/i
           when /folder|dir/i
              folder=value
           else
         end
         }
         captured_file =File.join(folder,filename)
         File.delete(captured_file) if File.exist?(captured_file)
         @existing_ie= Watir::IE.attach(:url, /selenium-server|Center/)            
         @existing_ie.wait
         @existing_ie.bring_to_front
         @existing_ie.visible=true
         @existing_ie.maximize
         @existing_ie.wait
         require 'win32screenshot'
         require 'RMagick'
         width, height,bitmap = Win32::Screenshot.window(/Guidewire/)
         my_imgage = Magick::ImageList.new.from_blob(bitmap)
         selenium_height = 109 + 260 # height*0.3#
         my_imgage.crop!(0, selenium_height, width, height-selenium_height)
         my_imgage.sample!(1024, 768)     
         my_imgage.write(captured_file)
         result="### screenshot captured into #{captured_file}"
         puts result
     rescue
         result += "### Error: problem to #{this_method}: "+$!.to_s
     end
     result
  end
  
end
