# Created by IntelliJ IDEA.
# User: jimsun
# Date: Dec 2, 2008
# Time: 11:27:07 PM
# To change this template use File | Settings | File Templates.

module RMagicHelper

  def self.screenshot(filename, path="c:\\tmp")
     begin
          filename = filename+".png"  if filename !~ /\.png$/
          require 'win32screenshot'
          require 'RMagick'
          width, height,bitmap = Win32::Screenshot.window(/Internet/)
          imgl = Magick::ImageList.new.from_blob(bitmap)
          imgl.crop!(0, 109, width, height-109)
          imgl.scale!(1024, 768)
          imgl.write(File.join(path,filename))
          puts("Screenshot captured: #{File.join(path,filename) }")

        rescue Exception => ex
          puts ex
        end
    end


end