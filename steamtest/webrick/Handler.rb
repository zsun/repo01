# Created by IntelliJ IDEA.
# User: jimsun
# Date: Aug 7, 2008
# Time: 4:49:33 PM
# To change this template use File | Settings | File Templates.


class Handler

  def handle (parameters={})
    raise NotImpelemntedError("#{self.class.name}#m1() is not implemented.")
  end
 
end