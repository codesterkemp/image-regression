require 'selenium-webdriver'

# main
def sel_main(link_list, output_dest)
  links = load_links(link_list)
  driver = Selenium::WebDriver.for :firefox
  links.each do |url|
    go_and_photo(url, output_dest, driver)
  end
  driver.close
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

def go_and_photo(url, output_dest, driver)
  safe_url = safe_url_name(url)
  driver.navigate.to url
  driver.save_screenshot output_dest+safe_url+'.png'
end

def safe_url_name(url)
  url.gsub(/[\W]+/,'_')
end

main("links.txt", "test_pics/")
