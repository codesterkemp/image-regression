require "./photo_page_mach.rb"
# sample input values
@sources = []

def live_urls?(inputs)
  !inputs.fetch('urls').empty?
end

def get_live_urls(inputs)
  source_set = []
  inputs.fetch('urls').each do |url_list|
    source_set << load_links(url_list)
  end
  source_set
end

def file_names?(inputs)
  !inputs.fetch('file_list').empty?
end

def get_file_names(inputs)
  while sources.length < 2 && !inputs.fetch('file_list').empty?
    @sources << inputs.fetch('file_list').shift
  end
end

def collect_files_from_weblinks(web_links)
  if web_links
    filename = ["live_links","dev_links"]
    spin_up_webdriver
    web_links.each_with_index do |link_list, i|
      file_list = []
      link_list.each_with_index do |link, j|
        file_list<< create_link_file(link)
      end
      @sources << write_text_to_file(file_list,filename[i])
    end
    close_down_webdriver
  end
end

def main(inputs)
  # url lists are processed if they are included in the input hash.
  if file_names?(inputs)
    get_file_names(inputs)
  end
  if live_urls?(inputs)
    web_links = get_live_urls(inputs)
  end
  collect_files_from_weblinks(web_links)

  image_overlay(@sources)

end

def image_overlay(sources, output_path = 'diff')
  input_a = File.open(sources[0], "r")
  input_b = File.open(sources[1], "r")
  name = "diff"
  diff_dir = mkdir(name)
  puts diff_dir
  while (line_a = input_a.gets && line_b = input_b.gets)
    line_a = line_a.to_s.chomp
    line_b = line_b.to_s.chomp
    diff_img(line_a,line_b,diff_dir)
  end
end

#depreciating methods

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

def dev_mode(live_urls,dev_urls,overwrite = false)
  file_names = []
  file_names << photo_web_pages(live_urls,live_urls+"img")
  file_names << photo_web_pages(dev_urls,dev_urls+"img")
  file_names
end

def hist_mode(current_urls)
  file_names = []
  file_names << photo_web_pages(current_urls,current_urls+"img")
  file_names
end

#unused methods
def prevent_overwrite(filename)
  filename = remove_text_file_ending(filename)
  i = 0
  the_end = ".txt"
  tempfilename = filename+the_end
  while File.exist?(tempfilename)
    tempfilename = filename + i.to_s + the_end
    i += 1
  end
  return tempfilename
end

def write_text_to_file(the_array, filename = 'filename', overwrite = false)
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
  return filename
end

#secondary methods

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

#convert to ruby with gems in the future below.

def diff_img(img_a,img_b, output_path)
  puts "#{output_path} is the output dir"
  system("composite #{img_a} #{img_b} -compose difference #{output_path}_diff_#{img_a}")
  system("convert #{img_a} #{img_b} #{output_path}_diff_#{img_a} +append _combined_#{img_a}")
end

def mkdir(name, path = ".")
  system("cd #{path}")
  return if system("cd #{name}")
  system("mkdir #{name}")
  system("cd #{name}")
  #returns new dir path
  hold = system("pwd")
  return hold
end

def photo_web_pages(link_file,dest_fold = ".")
  file_names = sel_main(link_file,dest_fold)
end

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

inputs = {
  'urls' => ['live_links_path_file.txt', 'dev_links_path_file.txt'],
  'dest_fold' =>'',
  'overwrite' =>false,
  'file_list' =>[],
}

main(inputs)
