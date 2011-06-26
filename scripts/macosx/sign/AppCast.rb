#!/usr/bin/env ruby -w

class AppCast
  require 'yaml'
  require 'tmpdir'
  require 'fileutils'

  MESSAGE_HEADER    = 'APPCAST BUILD MESSAGE'

  def initialize
    @signature = ''

   # ---------------------
    # edit this path to point to your folder that contains all your appcast application configs
    @configs_folder_path = '/Users/kez/Code/Appcasts/configs/'
    # ---------------------

   require_release_build
    instantiate_project_variables
    load_config_file
    instantiate_appcast_variables
  end

  def main_worker_bee
    create_appcast_folder_and_files
    remove_old_zip_create_new_zip
    file_stats
    create_key
    create_appcast_xml
    copy_archive_to_appcast_path
  end

  # Only works for Release builds
  # Exits upon failure
  def require_release_build
      if ENV["BUILD_STYLE"] != 'Release'
        log_message("Deployment target requires 'Release' build style")
        exit
      end
  end

  # Exits if no config.yaml file found.
  def load_config_file
  	project_name = ENV['PROJECT_NAME']
  	config_file_path = "#{@configs_folder_path}#{project_name}.yaml"
	if !File.exists?(config_file_path)
      log_message("No '#{project_name}.yaml' file found in configs directory.")
      exit
    end
    @config = YAML.load_file(config_file_path)
  end

  def instantiate_project_variables
    @proj_dir               = ENV['BUILT_PRODUCTS_DIR']
    @proj_name              = ENV['PROJECT_NAME']
    @version                = `defaults read "#{@proj_dir}/#{@proj_name}.app/Contents/Info" CFBundleVersion`
    @version                = @version.gsub(/\D+/,"")
    @short_version          = `defaults read "#{@proj_dir}/#{@proj_name}.app/Contents/Info" CFBundleShortVersionString`
    @archive_filename       = "#{@proj_name} #{@short_version.chomp}.zip"
    @archive_path           = "#{@proj_dir}/#{@archive_filename}"
  end

  def instantiate_appcast_variables
    @appcast_xml_name       = @config['appcast_xml_name'].chomp
    @appcast_basefolder     = @config['appcast_basefolder'].chomp
    @appcast_proj_folder    = "#{@config['appcast_basefolder']}/#{@proj_name}_#{@short_version}".chomp
    @appcast_xml_path       = "#{@appcast_proj_folder}/#{@appcast_xml_name}"
    @download_base_url      = @config['download_base_url']
    @keychain_privkey_name  = @config['keychain_privkey_name']
    @download_url           = "#{@download_base_url}#{@archive_filename}"
  end

  def remove_old_zip_create_new_zip
    Dir.chdir(@proj_dir)
    `rm -f #{@proj_name}*.zip`
    `zip -qr "#{@archive_filename}" "#{@proj_name}.app"`
  end

  def copy_archive_to_appcast_path
    begin
      FileUtils.cp(@archive_path, @appcast_proj_folder)
    rescue
      log_message("There was an error copying the zip file to appcast folder\nError: #{$!}")
    end
  end

  def file_stats
    @size     = File.size(@archive_filename)
    @pubdate  = `date +"%a, %d %b %G %T %z"`
  end

  def create_key
    priv_key_path = "#{Dir.tmpdir}/priv_key.pem"
	intermed_file = "#{Dir.tmpdir}/intermed_data"
    temp = `security find-generic-password -g -s "#{@keychain_privkey_name}" 2>&1 1>/dev/null \
				| perl -pe '($_) = /"(.+)"/'`

	 File.open(intermed_file, 'w+') { |f| f.puts temp.split("\\012") }

	 key = `perl -MXML::LibXML -e 'print XML::LibXML->new()->parse_file("#{intermed_file}")->findvalue(q(//string[preceding-sibling::key[1] = "NOTE"]))'`

	log_message(key)
    if key == ''
      log_message("Unable to load signing private key with name '#{@keychain_privkey_name}' from keychain\nFor file #{@archive_filename}")
      exit
    end

   File.open(priv_key_path, 'w+') { |f| f.puts key }

   @signature = `openssl dgst -sha1 -binary < '#{@archive_path}' \
                   | openssl dgst -dss1 -sign '#{priv_key_path}' \
                   | openssl enc -base64`

    `rm -fP #{priv_key_path}`
	`rm -fP #{intermed_file}`
    log_message(@signature)

    if @signature == ''
      log_message("Unable to sign file #{@archive_filename}")
      exit
    end
  end

  def create_appcast_xml
   # if the file exists it may have already been edited
   # so dont overwrite it
   if !File.exists?(@appcast_xml_path)

     appcast_xml =
    "<item>
	<title>Version #{@short_version.chomp}</title>
	 <description><![CDATA[
		<h2>New in #{@short_version.chomp}</h2>
		<ul>
                <li>Item 1</li>
                <li>Item 2</li>
         </ul>

		]]></description>
     <pubDate>#{@pubdate.chomp}</pubDate>
	<enclosure
		url=\"#{@download_url.chomp}\"
		sparkle:version=\"#{@version.chomp}\"
		sparkle:shortVersionString=\"#{@short_version.chomp}\"
		type=\"application/octet-stream\"
		length=\"#{@size}\"
		sparkle:dsaSignature=\"#{@signature.chomp}\"
	/>
    </item>"

    File.open(@appcast_xml_path, 'w') { |f| f.puts appcast_xml }
	else
		update_appcast_xml
    end
  end

  def update_appcast_xml
  	new_enclosure = "<pubDate>#{@pubdate.chomp}</pubDate>
	<enclosure
		url=\"#{@download_url.chomp}\"
		sparkle:version=\"#{@version.chomp}\"
		sparkle:shortVersionString=\"#{@short_version.chomp}\"
		type=\"application/octet-stream\"
		length=\"#{@size}\"
		sparkle:dsaSignature=\"#{@signature.chomp}\"
	/>
    </item>"

    File.open(@appcast_xml_path, 'r+') do |f|
    lines = f.readlines
	count = 0
	# remove all lines after and including the pubDate tag
    lines.each do |it|
       	if it =~ /<pubDate>/
       		break
       	end
    	count += 1
    end
    lines.slice!(count..-1)
    f.pos = 0
    f.print lines
	# add the new enclosure tags and close item tag
    f.print new_enclosure
    f.truncate(f.pos)
	end

  end

  # Creates the appcast folder if it does not exist
  # or is accidently moved or deleted

  def create_appcast_folder_and_files
    base_folder = @appcast_basefolder
    project_folder = @appcast_proj_folder

    Dir.mkdir(base_folder)    if !File.exists?(base_folder)
    Dir.mkdir(project_folder) if !File.exists?(project_folder)
  end

  def log_message(msg)
    puts "\n\n----------------------------------------------"
    puts MESSAGE_HEADER
    puts msg
    puts "----------------------------------------------\n\n"
  end
end

if __FILE__ == $0
  newAppcast = AppCast.new
  newAppcast.main_worker_bee
  newAppcast.log_message("It appears all went well with the build script!")
end