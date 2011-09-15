# Created by IntelliJ IDEA.
# User: jimsun
# Date: Jul 31, 2008
# Time: 5:52:43 PM
# To change this template use File | Settings | File Templates.


=begin
  Common top level utility functions
=end

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'uri'
require 'net/http'


###   modules

module MyRubyUtil
  
  def ping (url_to_ping)
    result="Bad"
    begin
      result = "#{Net::HTTP.get_response(URI.parse(url_to_ping)).code}"
    rescue Errno::EBADF => e
      result="Bad file descriptor - connect(2) (Errno::EBADF)"
      $!
    rescue
      result = "Bad unknown exception from doing ping!"
      $!
    end
    result
  end

  def wait_while (timeout)
    wait = true
    time_used = 0
    while wait do
      if time_used > timeout
        puts ("error, timed out at #{time_used} seconds")
        break
      end
      sleep 3
      time_used=time_used+3
      wait = false
      if block_given?
        wait = yield
      end
    end
  end
  def assert (msg="")
    raise "Assertion failed: #{msg}!" unless yield
  end
  def warning (msg="")
    if block_given?
      puts "*** Warning: #{msg}!" if yield
    else
      puts "*** Warning: #{msg}!"
    end
  end

  def service_looup (hostandport="localhost:8013")

    handler_files = ["AutoItHandler.rb",  "WatirHandler.rb" , "InetSoft.rb"
                     #"TomcatHandler.rb", "WeblogicHandler.rb", "WebsphereHandler.rb"
                    ]
    services =[]
    
    handler_files.each {|file|
      lines=""
      enter_handler_function = false
      # handler_name = file.downcase.sub(/{handler}(0,)\.rb/, "")
      handler_name = file.downcase.sub(/handler\.rb|\.rb/, "")
            
      open( File.join(File.expand_path(File.dirname(__FILE__)), file)).each { |line|
        enter_handler_function = false if enter_handler_function and line =~ /end/
        enter_handler_function = true if line =~ /def handle/
        if (enter_handler_function)

          if line.include?("when")
            cmd = ""
            line =~ /when\s+\/(.*)\//
            #line =~ /when\s+"(.*)?"/
            cmd =$1
            if ((not cmd.nil?) and cmd != "" )
              if handler_name == 'inetsoft'
                ["tomcat", "weblogic", "websphere"].each do |webserver|
                  services << "handler=#{webserver}&command=" + cmd.gsub("/i", "").gsub("/", "")
                end
              else
                services << "handler=#{handler_name}&command=" + cmd.gsub("/i", "").gsub("/", "")
              end
            end
          end
        end
        }      
      }      
    
      listing="list of services:\n"
      services.each do|c|
        #listing = listing + "<a href=\"http://#{hostandport}/#{c}\"/>\n"
        listing = listing + "http://#{hostandport}/#{c}\n"
      end
      listing
      #puts  listing
  end

  def clean_unecessary_processes (rubyserverport="-1")
    # only use this method with caution
    pslist = `tasklist | sort`
    ps_name_id_raw = pslist.split("\n")   
    ps_name_id = []
    ps_name_id_raw.each { |p|
      p.squeeze!   
      if (p =~/java\.exe/)
        t = p.split(/\s/)
        name, pid, terminal, other = t[0], t[1],t[2], t[3]
        ps_name_id << [name, pid]
      end
    }

    ps_name_id.each { |p|
      puts "#{p[0]} : #{p[1]}" 
    }
    ps_name_id.length.downto(3) {|i|
      cmd = "taskkill \/PID #{ps_name_id[i-1][1].strip} \/F"
      puts "cmd = #{cmd}"
      `#{cmd}`
    }

    if (rubyserverport!="-1")
      ps_with_port_raw = `netstat -ao`
      ps_with_port = []
      # get Local_Address and PID
      ps_with_port_raw.each { |p|
        p.squeeze!   
        if (p =~/TCP|UDP/)
          t = p.split(/\s/)
          localaddress, pid = t[0], t[4]
          ps_with_port << [localaddress, pid]
        end
      }

      ps_with_port.each { |p|
        puts "#{p[0]} : #{p[1]}"
      }


    #      ps_with_port.length.downto(0) {|i|
    #        if (ps_with_port[i-1][1].strip =~ rubyserverport)
    #          cmd = "taskkill \/PID #{ps_with_port[i-1][1].strip} \/F"
    #          puts "cmd = #{cmd}"
    #          `#{cmd}`
    #        end
    #      }
    end
   
  end
end


module IE_popup
 
  def popupChecker(the_ie_browser, text)
    sleep 2
    Timeout::timeout(10) do
      begin
        hwnd1 = the_ie_browser.enabled_popup(9)
        w = WinClicker.new
        # popup_text = w.getStaticText_hWnd(hwnd1)
        w.clickWindowsButton_hwnd(hwnd1, text )
      rescue Timeout::Error
        puts "No Popup existed"
      end
    end
  end

end

###   classes

class Object
  def this_method
    caller[0]=~/`(.*?)'/
    $1
  end
end

require 'watir'
class IeLauncher
  def IeLauncher.open(*args)
    result = ie = Watir::IE.start(*args)
    if block_given?
      begin
        result = yield ie
      ensure
        ie.close
      end
    end
    return result
  end
end

class Object
  def this_method
    caller[0]=~/`(.*?)'/
    $1
  end
end

def current_branch_dir


=begin
#e.g. C:/depot/eng/bedrock/active/pl/core/cc/qa/
  #C:\depot\eng\bedrock\active\pl\core\cc\modules\dev\config\resources\tests\gw\smoketest\cc\report
  thedir=Dir.pwd.sub("cc/qa/rubytest/webrick", "")
  thedir =thedir.gsub("/", "\\\\")
  # thedir=Dir.pwd.chdir("../../")
=end

  thedir = ENV['CURRENT_BRANCH'] if ENV['CURRENT_BRANCH'] != nil
  raise 'Error: did not find envrionmental variable: CURRENT_BRANCH (e.g. C:\depot\eng\bedrock\active\pl\core'  if thedir == nil
  return thedir

end
   
def hostname
  require "socket"
  Socket.gethostname
end
