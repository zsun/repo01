
require 'watir'
# http://wiki.openqa.org/display/WTR/FAQ

class InteractWithIE

  #testing
  @@existing_ie= Watir::IE.attach(:url, Regexp.new("http://th")   )
  @@existing_ie.wait
  puts "@existing_ie.url = " + @@existing_ie.url
  @@existing_ie.bring_to_front
  # sleep(10)

  #@existing_ie.select_lists.
  # @existing_ie.show_all_objects
  @@top_frame=@@existing_ie.frame(:name, "top_frame")
  #top_frame.show_all_objects
  def self.top_frame
    @@top_frame
  end
  def paging
    #select-one        name=Suites:SuitesScreen:SuitesLV:_ListPaging  id=Suites:SuitesScreen:SuitesLV:_ListPaging  value=1
    #@@existing_ie.show_all_objects
    # damn, the button Cancel is not a button, rather it is a link!!!!!!!
    @@top_frame.link(:id, /Suites:SuitesScreen:Cancel/).click if @@top_frame.link(:id, /Suites:SuitesScreen:Cancel/).exists?

    pager=@@top_frame.select_list(:id, /Suites:SuitesScreen:SuitesLV:_ListPaging/)
    pager.set(1)
    arr=pager.getAllContents.to_a
    arr.each{|page|
      puts("On page #{page} ... ")
      @@top_frame.link(:id, "Suites:SuitesScreen:Edit").click
      @@existing_ie.wait
      find_bad_suite_improved_3(page)

      @@top_frame.link(:id, "Suites:SuitesScreen:Cancel").click
      @@existing_ie.wait
      pager.set(page)
      #break if page.to_i > 5
    }

  end
  def find_bad_suite(page_number)
    versions_names =[]
    suite_versions = {}
    @@top_frame.text_fields.each{|item|
      #puts "looking at item:\n#{item}"
      if (item.id =~ /:(\d{1,2}):name$/)
        index=$1
        #puts "index = #{index}"
        versions_names.unshift(item)
        suite_versions[item]=@@top_frame.select_list(:id, /:#{$1}:suiteVersion/)
      end
    }
    #puts "suite_versions.size: #{suite_versions.size}"


    versions_names.each{|name|
     #if( (suite_versions[name].value != 'V3') and name.value =~ /v3/i )
        #puts("found a problem stuie: " + name.value)
      puts("XXX(1) found a problem suite #{suite_versions[name].value} : #{name.value}" ) if ((suite_versions[name].value != 'v3') and name.value =~ /v3/i )
      puts("XXX(2) found a problem suite #{suite_versions[name].value} : #{name.value}" ) if ((suite_versions[name].value == 'v3') and name.value !~ /v3/i )
     }


  end
  def find_bad_suite_improved(page_number)



    @@top_frame.text_fields.each{|name|
      suite_name=nil # ""
      version_value=nil #""
      if (name.id =~ /:(\d{1,2}):name$/)
        index=$1

        #2nd edition
        #version_dropdown=@@top_frame.select_list(:id, /:#{$1}:suiteVersion/)
        #version_dropdown=@@top_frame.select_list(:id, "Suites:SuitesScreen:SuitesLV::#{$1}:suiteVersion")

        suite_name=name.value
        # version_value=version_dropdown.value

        # 3rd edition
        version_value=@@top_frame.select_list(:id, "Suites:SuitesScreen:SuitesLV:#{$1}:suiteVersion").value

        puts("XXX(1) found a problem suite #{version_value} : #{suite_name}" ) if ((version_value != 'v3') and suite_name =~ /v3/i )
        puts("XXX(2) found a problem suite #{version_value} : #{suite_name}" ) if ((version_value == 'v3') and suite_name !~ /v3/i )
      end
    }
  end

  def find_bad_suite_improved_3(page_number)

    (0..24).each do |i|
      suite_name = @@top_frame.text_field(:id, "Suites:SuitesScreen:SuitesLV:#{i}:name").value
      version_value=@@top_frame.select_list(:id, "Suites:SuitesScreen:SuitesLV:#{i}:suiteVersion").value

      puts("XXX(1) found a problem suite #{version_value} : #{suite_name}" ) if ((version_value != 'v3') and suite_name =~ /v3/i )
      puts("XXX(2) found a problem suite #{version_value} : #{suite_name}" ) if ((version_value == 'v3') and suite_name !~ /v3/i )
    end
  end

  def show_all
    @@top_frame.show_all_objects
    #@@top_frame.text_fields.each{|t| puts t}

  end
  def test_text
    #text              name=Suites:SuitesScreen:SuitesLV:21:name  id=Suites:SuitesScreen:SuitesLV:21:name  value=abupgrade     alt=                src=
     @@top_frame.text_fields.each{|item|
       puts " looking at: #{item}"
       if item.id =~ /:name$/
         puts(item.value)
       end
    }

  end
  def test_setting_versions
    versions_names =[]
    @@top_frame.text_fields.each{|item|
      versions_names.unshift(item) if item.id =~ /:name$/
    }
    puts versions_names.size

    versions_dropdowns =[]
    @@top_frame.select_lists.each{|item|
      versions_dropdowns.unshift(item) if item.id =~ /:suiteVersion/
    }

    suite_versions = {}
    versions_names.each_index{|index|
      suite_versions[versions_names[index]]=versions_dropdowns[index]
    }
    versions_names.each{|name|
      #puts  name.value
      #puts suite_versions[name].value
      suite_versions[name].set("V3") if name.value =~/v3/i
    }

  end
  def test_setting_versions_2
=begin
text              name=Suites:SuitesScreen:SuitesLV:24:name  id=Suites:SuitesScreen:SuitesLV:24:name  value=pcfinancialsv3  alt=                src=
select-one        name=Suites:SuitesScreen:SuitesLV:24:eproduct  id=Suites:SuitesScreen:SuitesLV:24:eproduct  value=Product:2
checkbox          name=Suites:SuitesScreen:SuitesLV:24:dynamic  id=Suites:SuitesScreen:SuitesLV:24:dynamic  value=true          alt=                src=
checkbox          name=Suites:SuitesScreen:SuitesLV:24:nightly  id=Suites:SuitesScreen:SuitesLV:24:nightly  value=true          alt=                src=
checkbox          name=Suites:SuitesScreen:SuitesLV:24:RunOnStable  id=Suites:SuitesScreen:SuitesLV:24:RunOnStable  value=true          alt=                src=
checkbox          name=Suites:SuitesScreen:SuitesLV:24:RunOnMerge  id=Suites:SuitesScreen:SuitesLV:24:RunOnMerge  value=true          alt=                src=
checkbox          name=Suites:SuitesScreen:SuitesLV:24:RunRelease  id=Suites:SuitesScreen:SuitesLV:24:RunRelease  value=true          alt=                src=
checkbox          name=Suites:SuitesScreen:SuitesLV:24:perfSuite  id=Suites:SuitesScreen:SuitesLV:24:perfSuite  value=true          alt=                src=
select-one        name=Suites:SuitesScreen:SuitesLV:24:suiteVersion  id=Suites:SuitesScreen:SuitesLV:24:suiteVersion  value=v3
=end

    versions_names =[]
    suite_versions = {}
    @@top_frame.text_fields.each{|item|
      versions_names.unshift(item) if item.id =~ /:(.*):name$/
      index=$1
      suite_versions[item]=@@top_frame.select_list(:id, /:#{$1}:suiteVersion/)
    }
    puts suite_versions.size


    versions_names.each{|name|
      puts  name.value
      #puts suite_versions[name].value
      suite_versions[name].set("V3") if name.value =~/v3/i
    }

  end
  def test_versions
    #select-one        name=Suites:SuitesScreen:SuitesLV:1:suiteVersion  id=Suites:SuitesScreen:SuitesLV:1:suiteVersion  value=v2
    versions_dropdowns =[]
    @@top_frame.select_lists.each{|item|
      versions_dropdowns.unshift(item) if item.id =~ /:suiteVersion/
    }
    puts "initially:"
    versions_dropdowns.each{|item|
      item.set("V3")
    }
    versions_dropdowns.each{|item|
      puts item.id+ " value = " + item.value
    }
    puts "after update:"
    versions_dropdowns.each{|item|
      puts item.id+ " value = " + item.value
    }
    puts("done")
  end
end


th=InteractWithIE.new
t1 = Time.now
# th.test_versions
#th.show_all
#th.test_text
#th.test_setting_versions_2

th.paging

t2 = Time.now
puts "Time taken: #{t2-t1} seconds"
=begin
existing_ie= Watir::IE.attach(:url, Regexp.new("http://th")   )
  existing_ie.wait
  puts "@existing_ie.url = " + existing_ie.url
  existing_ie.bring_to_front

  top_frame=existing_ie.frame(:name, "top_frame")
  top_frame.show_all_objects
  top_frame.link(:id, "Suites:SuitesScreen:Cancel").click
=end