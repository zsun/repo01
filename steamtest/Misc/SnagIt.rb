# Created by IntelliJ IDEA.
# User: jimsun
# Date: Dec 2, 2008
# Time: 5:36:48 PM
# To change this template use File | Settings | File Templates.
module SnagIt

  def self.screenshot(filename, path="c:\\tmp")
     begin
          filename = filename.sub(/\.png/, "") if filename =~ /\.png$/            
          require 'win32ole'
          snagit = WIN32OLE.new('Snagit.ImageCapture')                    
          snagit.Input = 1          
          snagit.Output = 2 
          snagit.OutputImageFile2.FileType = 5
          snagit.OutputImageFile2.FileNamingMethod = 1  
          snagit.OutputImageFile2.Directory = path   
          snagit.OutputImageFile2.Filename = filename
          snagit.InputWindowOptions.SelectionMethod=3
          snagit.InputWindowOptions.XPos =600
          snagit.InputWindowOptions.YPos =700            
          snagit.Capture

          until snagit.IsCaptureDone do
            sleep 0.5
          end
          puts("screenshot captured: #{path}\\#{filename}.png")
        rescue Exception => ex
          puts ex
        end
    end


end