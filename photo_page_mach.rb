require 'selenium-webdriver'

def spin_up_webdriver
  @driver = Selenium::WebDriver.for :firefox
end

def close_down_webdriver
  @driver.close
end


# main
def sel_main(link_list, output_dest)
  links = load_links(link_list)
  unless @driver
    spin_up_webdriver
  else
    driver = @driver
    close = false
  end
  img_file_list = []
  links.each do |url|
    img_file_list << go_and_photo(url, output_dest, driver)
  end
  if close
    driver.close
  end
  img_file_list
end

# load link list
def load_links(text_file_name)
  url_list_array = []
  input = File.open(text_file_name, 'r')
  while (line = input.gets)
    url_list_array << line.to_s.chomp
  end
  input.close
  url_list_array
end

def create_link_file(url)
  filename = go_and_photo(url)
end

def go_and_photo(url)
  safe_url = safe_url_name(url)
  @driver.navigate.to url
  @driver.save_screenshot safe_url+'.png'
  image_name = safe_url+'.png'
  puts image_name
  return image_name
end

def safe_url_name(url)
  url.gsub(/[\W]+/, '_')
end

#checks for a file named links.txt and executes if it exists
if File.exist?("links.txt")
  main("links.txt", "")
end

#for Selenium the http:// or https:// are required
#link list format
#http://www.example.com/firstpage
#https://www.example.com/some_other_page
#http://www.example.com/index?some_param

#which will go the pages and create these .png
#http_www_example_com_firstpage.png
#https_www_example_com_some_other_page
#http_www_example_com_index_some_param
