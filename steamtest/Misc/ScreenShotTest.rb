# Created by IntelliJ IDEA.
# User: jimsun
# Date: Dec 1, 2008
# Time: 10:25:57 PM
# To change this template use File | Settings | File Templates.



$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'watir'
include Watir
require 'unittests/setup'
require 'SnagIt'

class TC_ScreenShot < Test::Unit::TestCase

  $longin_username = "Login:LoginScreen:LoginDV:username"
  $login_password  = "Login:LoginScreen:LoginDV:password"
  $login_submit    = "Login:LoginScreen:LoginDV:submit"
  $ccurl           = "http://rhino:11500/cc/ClaimCenter.do"
  $policyType      = "FNOLWizard:FNOLWizard_FindPolicyScreen:FNOLWizardFindPolicyPanelSet:PolicyType"

  
  def get_login_page
      $ie.bring_to_front
      $ie.maximize
      $ie.goto($ccurl)
      $topframe=$ie.frame(:name, "top_frame")
  end

  def test_ScreenShot
      get_login_page
      SnagIt.screenshot("_before_login")
      $topframe.text_field(:id, $longin_username).set("aapplegate")
      $topframe.text_field(:id, $login_password).set("gw")
      $topframe.button(:id, $login_submit).click
      SnagIt.screenshot("_after_login")

      wait_until {$topframe.link(:id, "TabBar:ClaimTab_arrow").exists?}
      $topframe.link(:id, "TabBar:ClaimTab_arrow").click
      $topframe.span(:id, "TabBar:ClaimTab:ClaimTab_FNOLWizard").click
      SnagIt.screenshot("_new_claim_wizard")

      wait_until {$topframe.select_list(:id, $policyType).exists?}
      $topframe.select_list(:id, $policyType).select("Personal auto")
      SnagIt.screenshot("_PolicyType_searchpage")
      
  end
end
