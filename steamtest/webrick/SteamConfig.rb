# Created by IntelliJ IDEA.
# User: kzhang
# Date: Dec 23, 2008
# Time: 10:16:03 AM
# To change this template use File | Settings | File Templates.

module SteamConfig

  # Note: Do not checkin this file, this is the configuration that
  #       you can change freely on your local machine
  
  ###########################################################
  # config section for InetSoft report testing
  ###########################################################  
   ServerPort_tomcat="7171"
   SreeHome_tomcat = "c:\\Tomcat 6.0.18\\webapps"
  # ServerPort_tomcat="7070"
  # SreeHome_tomcat = "C:\\apache-tomcat-6.0.14\\webapps"

  ServerPort_weblogic="7001"
  SreeHome_weblogic = "C:\\bea\\jim"

  ServerAdminPort_websphere="9060"
  ServerPort_websphere="9080"  # WebSphere server admin port is 9060
  SreeHome_websphere = "C:\\Program Files (x86)\\IBM\\WebSphere\\AppServer\\profiles\\AppSrv01\\installedApps\\"+hostname+"Node01Cell\\sree_war.ear\\sree.war"
  
  ###########################################################
  # section for printing test
  ###########################################################

  ###########################################################
  # section for document management
  ###########################################################



end