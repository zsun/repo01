# feature tests for minimizing and maximizing IE windows
# revision: $Revision: 958 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_MinMax< Test::Unit::TestCase
  include Watir
  def setup
    $ie.goto($htmlRoot + 'pass.html')
  end        
  def teardown
    $ie.restore
  end
  def test_minimimum
    $ie.minimize
  end
  def test_maximum
    $ie.maximize
  end
  def test_front
    assert $ie.front?
    ie2 = IE.start($htmlRoot + 'blankpage.html')
    assert ie2.front?
    assert_false $ie.front?
    $ie.bring_to_front
    assert $ie.front?
    ie2.close
  end
end

