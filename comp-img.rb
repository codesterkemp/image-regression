require "photo_page_mach.rb"

def dev_mode(live_urls,dev_urls,overwrite = false)
  photo_web_pages(live_urls,live_urls+"img")
  photo_web_pages(dev_urls,dev_urls+"img")
end

def hist_mode(current_urls)
  grab_them_all(current_urls,current_urls+"img")
end

def photo_web_pages(link_file,dest_fold)
  sel_main(link_file,dest_fold)
  return
end

def remove_text_file_ending(filename)
  if filename.slice(-4, filename.length) == '.txt'
    return filename.slice(0, filename.length - 4)
  end
  return filename
end

def add_text_ending(filename)
  if filename.slice(-4, filename.length) == '.txt'
    return filename
  end
  filename += '.txt'
end

def prevent_overwrite(filename)
  i = 0
  the_end = ".txt"
  tempfilename = filename+the_end
  while File.exist?(tempfilename)
    tempfilename = the_start + i.to_s + the_end
    i += 1
  end
  return the_start+i.to_s
end

def write_text_to_file(the_array, filename = 'filename', overwrite = false)
  filename = remove_text_file_ending(filename)
  unless overwrite
    filename = prevent_overwrite(filename)
  end
  filename = add_text_ending(filename)
  the_file = open(filename, 'w')
  the_file.truncate(0)
  the_array.each do |elem|
    the_file.write("#{elem}\n")
  end
  the_file.close
end

### GREEN ZONE BELOW

def parse_csv(csv_file, seperator = ';')
  input = File.open(csv_file, 'r')
  split_lines = []
  while (line_raw = input.gets)
    line_raw = line_raw.to_s.chomp
    line = line_raw.split('"').join('')
    if !split_lines.empty?
      line = line.split(seperator)
      i = 0
      line.each do |elem|
        puts elem
        split_lines[i] << elem
        i += 1
      end
    else
      split_lines = line.split(seperator)
      split_lines.each_with_index do |elem, k|
        elem = elem.split('  ')
        split_lines[k] = elem
      end
    end
  end
  puts split_lines[2].length
  split_lines
end

#brittle
def grab_path_from_file_name(filename)
  filename = filename.split('/')
  filename.pop
  filename = filename.join('/')
  filename+'/'
end

def grab_filename_from_path(fullpath)
  fullpath = fullpath.split('/')
  fullpath.pop
end


def parse_grabthemall_csv_for_img_name(csv_file)
  file_path = grab_path_from_file_name(csv_file)
  csv_array = parse_csv(csv_file)
  csv_array[2].shift
  full_file_name = file_path + 'img_file_list.txt'
  # puts full_file_name
  the_file = File.open(full_file_name, 'w')
  the_file.truncate(0)
  csv_array[2].each do |elem|
    # puts "#{elem}"
    the_file.write("#{elem}\n")
  end
  the_file.close
  full_file_name
end

#testing

def image_overlay(source_a,source_b)
  input_a = File.open(source_a, "r")
  input_b = File.open(source_b, "r")
  name = "diff"
  diff_dir = mkdir(name)
  path_a = grab_path_from_file_name(source_a)
  path_b = grab_path_from_file_name(source_b)
  while (line_a = input_a.gets && line_b = input_b.gets)
    line_a = line_a.to_s.chomp
    line_b = line_b.to_s.chomp
    diff_img(path_a+line_a,path_b+line_b,diff_dir)
  end
end


def diff_img(img_a,img_b, output_path)
  puts img_a
  puts "#{img_b} second image path"
  puts "\n" * 2
  ending = grab_filename_from_path(img_a)
  system("composite #{img_a} #{img_b} -compose difference #{output_path}_diff_#{ending}")
  system("convert #{img_a} #{img_b} #{output_path}_diff_#{ending} +append #{output_path}_combined_#{ending}")
end

def mkdir(name, path = ".")
  system("cd #{path}")
  return if system("cd #{name}")
  system("mkdir #{name}")
  system("cd #{name}")
  #returns new dir path
  system("pwd")
end

# Selenium section

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


filename ="/Users/codykemp/Projects/test-img-grab/_report_20150806_055222.csv"
filename2 = "/Users/codykemp/Projects/test-img-grab2/_report_20150806_055222.csv"
list_a = parse_grabthemall_csv_for_img_name(filename)
list_b = parse_grabthemall_csv_for_img_name(filename2)
image_overlay(list_a, list_b)
