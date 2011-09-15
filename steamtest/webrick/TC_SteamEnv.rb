# Created by IntelliJ IDEA.
# User: jimsun
# Date: Sep 17, 2008
# Time: 9:21:42 AM
# To change this template use File | Settings | File Templates.
require "MyRubyUtil"
include MyRubyUtil
require 'InetSoft'
require 'WatirHandler'
require 'WeblogicHandler'
require 'WebsphereHandler'
require 'TomcatHandler'
require "test/unit"

class TC_SteamEnv < Test::Unit::TestCase

 def setup
     @server_handlers = [      
      TomcatHandler.new, WebsphereHandler.new, WeblogicHandler.new
   ]
   end

  def teardown
    # Do nothing
  end


  def test_ruby_lib

    # test to make sure that the P4 branch that you are working in got a place in RUBYLIB array
    
    found_current_branch = false
    current_branch_path=current_branch_dir()
    puts "The branch that you are in: #{current_branch_path}"
    
    assert(found_current_branch != nil , "Did not find current branch represented by CURRENT_BRANCH envrionmental variable")
  end

  def test_watir_lib_path
    # test to make sure that Watir lib is in your RUBYLIB array
    found = false
    $:.each {|p|
      (found=true;  break) if p.include?("C:\\depot\\tools\\ruby\\win32\\lib\\ruby\\gems\\1.8\\gems\\watir-1.5.3")
    }
    assert(found , "Did not find Watir lib in the RUBYLIB")
  end


   def test_watir_lib_path
     # test to make sure that Watir lib is in your RUBYLIB array
     require "watir"     
     assert_match(/1\.5\.[3..9]/, Watir::IE::VERSION, "Did not find reqired Watir package")     
  end

  def test_autoit_dll_exists
    assert(File.exists?("C:\\depot\\tools\\ruby\\win32\\autoit_dll\\AutoItX3_x64.dll") , "Did not find autoit dll to register")
  end

  

end