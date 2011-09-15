require 'win32ole'

class AutoItHandler  < Handler
  def initialize

   autoit_dll=File.join(File.dirname(__FILE__), 'autoit_dll', 'AutoItX3.dll')
   puts `REGSVR32.exe /s #{autoit_dll}`   

   $autoit = WIN32OLE.new('AutoItX3.Control')
   $autoit.Opt('WinTitleMatchMode', 2)
   $autoitLagTime=3
   
  end

 # todo: close IE by tab rather than the whole IE browser 

  def handle(parameters={})
    command = !parameters.empty? && parameters.has_key?("command") ? parameters["command"] : nil
    puts "handler was asked to do: #{command} ..."    
    unless parameters.empty?
       case command
         when /closedialog/i
             # .rtf
            dialog_title = !parameters.empty? && parameters.has_key?("dialog_title") ? parameters["dialog_title"] : 'Adobe Sample'
            puts "closing dialog : #{dialog_title}"
            msg = closeDialog(dialog_title)
            if msg !~ /did not find dialog/
              "ok, dialog with title: #{dialog_title} closed!" 
            else
              msg
            end
         when /closepdf/i
              msg = closeDialog('Adobe Read')
              if msg !~ /did not find dialog/
                  "ok, dialog with title: #{dialog_title} closed!" 
                else
                  msg
                end
         when /savepdf/i
            filename = !parameters.empty? && parameters.has_key?("filename") ? parameters["filename"] : 'mypdf.pdf'
            location = !parameters.empty? && parameters.has_key?("location") ? parameters["location"] : "c:\\tmp"
            savePdf(filename, location)
            "ok, pdf file #{filename} saved into #{location}"
       when /print_to_text_file/i              
              filename = !parameters.empty? && parameters.has_key?("filename") ? parameters["filename"] : 'c:\tmp\mypdf.txt'
              filename="c:\\tmp\\"+filename if filename !~ /:/
              print_to_text_file(filename)
              "ok, pdf file printed to txt file!"
       when /savetocsv/i
         puts "to do save csv file"
             filename = !parameters.empty? && parameters.has_key?("filename") ? parameters["filename"] : 'c:\tmp\mycsv.csv'
             filename="c:\\tmp\\"+filename if filename !~ /:/
             puts "Saving to csv file: #{filename}"
             saveToCSV(filename)
             "ok, csv file saved!"
       
       when /save_txt_notepad/i  # save the content of notepad into a temp file
             puts "to do save .txt file from notepad ..."
             filename = !parameters.empty? && parameters.has_key?("filename") ? parameters["filename"] : 'c:\tmp\mytxt.txt'
             # filename="c:\\tmp\\"+filename if filename !~ /:/
             filename="c:\\tmp\\"+filename if filename !~ /:/
             puts "Saving to txt file: #{filename}"
             save_txt_notepad(filename)
             "ok, txt file saved!"
       
       when /save_and_close_txt_notepad|save_and_close_notepad/i
             puts "to do  save and close .txt file from notepad ..."
             filename = !parameters.empty? && parameters.has_key?("filename") ? parameters["filename"] : 'c:\tmp\mytxt.txt'
             # filename="c:\\tmp\\"+filename if filename !~ /:/
             filename="c:\\tmp\\"+filename if filename !~ /:/
             puts "Saving to txt file: #{filename}"
             save_txt_notepad(filename)
             closeDialog("- Notepad")
       when /pdfexists/i
            pdfExists?
       when /launchpdfdialog/i
            launchPdfDialog
       when /pdfexists/i
            pdfExists?
       when /choosefile/i  # choose a file location

            filename = !parameters.empty? && parameters.has_key?("filename") ? parameters["filename"] : 'no_filename_specified'
            filename=filename.gsub("___", "\\")
            puts "filename = #{filename}"
            choosefile (filename)
       else
            "Warning - command not supported - #{command}"
        end
    end


  end

 def choosefile (filename)
      require 'watir'
      ie=Watir::IE.attach(:url, /selenium-server|Center\.do/)
      ie.wait
      #the browse button click will freeze the GW test, let's do it in watir solely
      puts "click on the browse button "
      # here we will be using the textfield instead of the button to invoke the choosefile dialog
      #ie.frame(:name, "selenium_myiframe").frame(:name, "top_frame").text_field(:id, /[DocumentFile_txt|Attachment_txt]$/).click_no_wait()
      puts "found the browse text field" if ie.frame(:name, "selenium_myiframe").frame(:name, "top_frame").text_field(:id, /_txt$/).exists?
      ie.frame(:name, "selenium_myiframe").frame(:name, "top_frame").text_field(:id, /_txt$/).click_no_wait()
      sleep 3
      #http://localhost:8013/rubyhelper?handler=autoit&command=choosefile&filename=c:___tmp___blank1003.pdf
      puts "to choosefile location using the \"Choose File dialog\" ..."
      sleep 2
      title= "Choose File"
      _wait_dialog_with_title title

      _specify_file_location(filename, title)
      sleep 3
      puts "ok, choosefile executed!"
      "ok, choosefile executed!"
 end
 def closeDialog(titleHint)
   _close_dialog_with_title titleHint
 end

 def print_to_text_filelaunchPdf()    # todo: to be removed
   myprogram="\"C:\\Program Files (x86)\\Adobe\\Reader 8.0\\Reader\\AcroRd32.exe\""   
   myfile=current_branch_dir +"cc\\qa\\rubytest\\webrick_1\\AcrobatSample.pdf"
   mycomd="#{myprogram} #{myfile}"
   puts "mycomd: #{mycomd}"
   $autoit.Run "#{myprogram}", "", $autoit.SW_MAXIMIZE


   $autoit.WinWait('Adobe Read', nil, 20)
 end
 def hello
   return "Hello, this is the autoit server"
 end
 def pdfExists?
     existed=false
     existed = true if $autoit.WinExists("Adobe Read")
     return existed
 end

 def savePdf(filename='mypdf.pdf', location="c:\\tmp")
        # to close the openned new document window
        begin
            titlehint="Adobe Read"
            File.delete(location+"\\"+filename)  if File.exists?(location+"\\"+filename)
            sleep 3

              titlehint

            puts "sending ctrl+shift+s..."
            $autoit.Send("^+s")
            _wait_dialog_with_title "Save a"   #Save a Copy ...""


            _specify_file_location(location+"\\"+filename, "Save a" )


            _close_dialog_with_title("Adobe Read") #the pdf dialog file name changed after save as
            
        rescue
            puts "Error to savePdf: "+$!.to_s
            raise
        end
    end
 def save_txt_notepad (filename='txt', location="c:\\tmp")
          # to close the openned new txt document note pad window after saving to txt file
          # http://localhost:8013/rubyhelper?handler=autoit&command=save_and_close_txt_notepad&filename=jjj
          begin
              puts "In save_and_close_txt_notepad() ..."
              titlehint="- Notepad"
              filename=filename+".txt" if filename != /\.txt$/i
              file_to_save_into = filename !~ /:/ ? location+"\\"+filename : filename
              File.delete(file_to_save_into)  if File.exists?(file_to_save_into)
              sleep 3

              _wait_dialog_with_title titlehint

              print "Do a Alt-f-a key strokes ...\n"
              $autoit.Send("!fa")
              titlehint_2= "Save As"   #Save a Copy ...""  #note: case sensitive for the title
              _wait_dialog_with_title titlehint_2

              _specify_file_location(file_to_save_into, titlehint_2 )

          rescue
              puts "Error to save txt file: "+$!.to_s
              raise
          end
      end

 def saveToCSV(filename='mycsv.csv', location="c:\\tmp")
        # to close the openned new document window
        begin
            puts "In saveToCSV() ..."
            titlehint="File Download" # the 1st dialog after clicking to export to csv file for printing tests
            file_to_save_into = filename !~ /:/ ? location+"\\"+filename : filename 
            File.delete(file_to_save_into)  if File.exists?(file_to_save_into)
            sleep 3

            oldvalue = $autoit.Opt("WinTitleMatchMode", 2)            

            _wait_dialog_with_title titlehint

            $title = $autoit.WinGetTitle titlehint, ""

            _click_savebutton_on_dialog ($title)
            
            titlehint_2= "Save As"   #Save a Copy ...""  #note: case sensitive for the title
            _wait_dialog_with_title titlehint_2
                        
              _specify_file_location(file_to_save_into, titlehint_2 )

            # there might be a dialog "Download complete" showing up after the save
            begin
              titlehint_3= "Download complete"
              _wait_dialog_with_title titlehint_3
              
              $title_3 = $autoit.WinGetTitle titlehint_3, ""
              puts "clicking on the Close button"
              
              $autoit.ControlClick($title_3, "", "Button4")  #close button
              $autoit.WinWaitClose($title_3, nil, 10)

            rescue  => detail
              print detail.backtrace.join("\n")
            end

            
        rescue
            puts "Error to save csv: "+$!.to_s
            raise
        end
    end
def print_to_text_file(filename='c:\tmp\mypdf.txt')   # for print pdf file into txt file

        exportedfile=""
        begin
            puts "inside serverlet: print_to_text_file"
            File.delete(filename)  if File.exists?(filename)
            puts   "temp export destination txt file to use: "+ filename
            filename =filename.split(/\./).first
            $button_id=0
            $string_to_send="o"
            
            sleep $autoitLagTime            

            $title="File Download"
            _wait_dialog_with_title $title

            
            # click on the open button
            $autoit.ControlClick($title, "", "Button1")
            if $autoit.WinExists( $title)
                $autoit.WinActivate($title)
                $autoit.ControlClick($title, "", "Button1")
            end
            if $autoit.WinExists( $title)
                $autoit.WinActivate($title)
                $autoit.ControlClick($title, "", "Button1")
            end

            begin
                1.upto(3) do
                    break unless $autoit.WinExists($title, "Do you want to open")
                    $autoit.ControlClick($title, "Do you want to open or save this file", "&Open", "left", 1)
                    sleep 2
                end
                if $autoit.WinExists($title, "Adobe Reader")
                    $autoit.WinActive($title)
                    $autoit.ControlClick($title, "Do you want to open or save this file", "&Open", "left", 3)
                    counter=0
                    while $autoit.WinExists($title, "Do you want to open")
                        break if counter>3
                        sleep 1
                        counter=counter+1
                        $autoit.WinActive($title)
                        $autoit.ControlClick($title, "Do you want to open or save this file", "&Open", "left", 3)
                    end

                end
            rescue
                puts "Error to do print_to_txtfile: "+$!.to_s
            end

            $title_2   = "Adobe"
            $autoit.WinWait($title_2 , nil, 10)            
            $title_2 = $autoit.WinGetTitle "Adobe", ""

            $autoit.WinWait($title_2 , nil, 10) if $title_2=="0" 
            $title_2 = $autoit.WinGetTitle "Adobe", ""

            puts "The adobe file window title: "+$title_2

            print "Do a Alt-f-v key strokes ...\n"
            $autoit.WinActivate $title_2
            $autoit.Send("!fv")

            $title_save_a_copy = "Save As"
            $autoit.WinWait($title_save_a_copy , nil, 30)            

            #now we are on the Save as dialog
            $autoit.ControlCommand($title_save_a_copy, "", "ComboBox3", "SelectString", "Text (Accessible) (*.txt)")
            $autoit.ControlCommand($title_save_a_copy, "", "ComboBox3", "SelectString", "Text (Accessible) (*.txt)")
            $autoit.ControlSetText($title_save_a_copy, "", "Edit1", filename)
            $autoit.ControlSetText($title_save_a_copy, "", "Edit1", filename)

            $autoit.ControlCommand($title_save_a_copy, "", "ComboBox3", "SelectString", "Text (Accessible) (*.txt)")
            target_file_ext = $autoit.ControlCommand($title_save_a_copy, "", "ComboBox3", "GetCurrentSelection", "")            
            
            $autoit.ControlSetText($title_save_a_copy, "", "Edit1", filename+".txt")
            $autoit.ControlSetText($title_save_a_copy, "", "Edit1", filename+".txt")

            $autoit.ControlSetText($title_save_a_copy, "", "Edit1", filename+".txt")            

            exportedfile=$autoit.ControlGetText( $title_save_a_copy, "", "Edit1")
            puts "exporting into txt file: " +  exportedfile
            $autoit.ControlClick($title_save_a_copy, "", "Button2")
            $autoit.WinWaitClose($title_save_a_copy, nil, 15)

            sleep 3
            timeout=0
            while (not File.exist?(filename+".txt") and not File.readable?(filename+".txt"))
                if timeout>=40
                    puts "error: Timeout on exporting txt file!"
                    break
                end
                sleep 2
                timeout=timeout+2
            end

            file_save_done = false
            begin
              while (!file_save_done)
                  fs1= File.size?(filename+".txt")
                  sleep 2
                  fs2= File.size?(filename+".txt")
                  if    (fs2 > fs1)
                    sleep 10
                    puts "sleep 10 sec"
                  else
                    file_save_done = true
                    puts "file save done"
                  end

              end
            rescue  => detail
              print detail.backtrace.join("\n")
            end

            _close_dialog_with_title("Adobe Reader")

        rescue
            puts "Error to do print_to_txtfile: "+$!.to_s
            raise
        end
        exportedfile

 end

  ##########################################################
  # utility methods
  ##########################################################
  private
  def _wait_dialog_with_title (titlehint)    
    $autoit.WinWait(titlehint, nil, 20)
    title = $autoit.WinGetTitle titlehint, ""
    puts "_wait_dialog_with_title :: Full title of the dialog: " +  title
    return "did not find dialog for #{titlehint}" if title == nil or title == "" or title == "0"
    $autoit.WinWait(title, nil, 30)
    $autoit.WinActive(title)
    $autoit.WinActivate(title)
    sleep 2
    "wait ok"
  end
  def _close_dialog_with_title(titleHint)
   sleep 30
   success = _wait_dialog_with_title titleHint
   return success if success =~ /did not find dialog/
   begin
       title = $autoit.WinGetTitle titleHint, ''
       puts "got dialog title: " + title
       $autoit.WinWait("[active]", nil, 20)
       $autoit.WinActive("[active]")
       $autoit.WinKill("[active]")
       $autoit.WinWaitClose("[active]", nil, 30)
       success_msg = "dialog of #{titleHint} should have been closed"
   rescue
       success_msg = "Did not find dialog with title of #{titleHint}"
   end
   puts success_msg
   success_msg
  end
  def _click_savebutton_on_dialog (title)
      $autoit.WinActivate(title)
      $autoit.ControlClick(title, "", "Button2")  #save button
  end
  def _specify_file_location (file_to_save_into, dialog_title)
    puts "specifying the file name and location"
    $autoit.ControlSend(dialog_title, "", "Edit1", file_to_save_into)
    begin_time = Time.now
    $autoit.ControlClick(dialog_title, "", "Button2")  #save button
    $autoit.WinWaitClose(dialog_title, nil, 10)
    end_time = Time.now
    puts "time taken for setting file location: #{end_time-begin_time} seconds"
  end
end





