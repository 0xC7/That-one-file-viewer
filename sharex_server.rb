# Requires
require "sinatra"
require "sinatra/content_for"
require "sinatra/config_file"
require "active_support"
require "active_support/core_ext/numeric/conversions"
require "tilt/haml"
require "tilt/sass"
require "logger"
require "fastimage"

# Helpers
require_relative "helpers/file_helper"
require_relative "helpers/haml_helper"
helpers FileHelper, HamlHelper

set :server, %w[puma webrick]
set :environment, :production

# Logging
logger = Logger.new('server.log', 'monthly')
logger.level = Logger::INFO

# Set Default Config
set :brand,     "0xC7"
set :copyright, "0xC7"
set :page_titles, {
                    image:   "Image Viewer",
                    video:   "Video Player",
                    audio:   "Audio Player",
                    archive: "File Sharer",
                    paste:   "Pastebin"
                  }
set :theme, "light"

# Require User Config
config_file "config/basic_cfg.yml"

Haml::Options.defaults[:ugly] = true
Haml::Options.defaults[:remove_whitespace] = true

puts "Starting up in #{settings.environment}"

get "/favicon.ico" do;end # Ignore this for the next route

get "/:id/?" do
  logger.info "Displaying #{params[:id].to_s} to #{request.ip}"
  @data = validate_file params[:id]
  @extension = file_ext(@data[:file])
  @humanrsize = File.size(@data[:file]).to_s(:human_size)
  #  check for image first
  if @data[:type] == "image"
    @width = FastImage.size(@data[:file]).first
    @height = FastImage.size(@data[:file]).last
    @grcmdv = @width.gcd(@height)
    # I'm horrible at math, don't hate me.
    @trueratio = (@width.to_f/@height.to_f)
    case (@trueratio)
    when (16.0/9.0)
      @ratio = "16:9"
    when (21.0/9.0)
      @ratio = "21:9"
    when (8.0/5.0)
      @ratio = "8:5"
    when (4.0/3.0)
      @ratio = "4:3"
    else
      @ratio = "#{@trueratio.round(5)}:1"
    end
  end

  return @data unless @data.is_a?(Hash)
  status 200
  haml :show, locals: {type: :show, object: @data[:type]}
end

get "/:id/download/?" do
  logger.info "Serving #{params[:id].to_s} to #{request.ip}"
  data = validate_file params[:id]
  return data unless data.is_a?(Hash)
  status 200
  send_file data[:file], disposition: :attachment, type: "application/octet-stream"
end

get "/scss/:style.scss" do
  content_type "text/css", charset: "utf-8"
  scss(:"assets/scss/#{params[:style]}", style: :compressed)
end

get "/js/:script.js" do
  content_type "text/javascript", charset: "utf-8"
  send_file "views/assets/js/#{params[:script]}.js"
end

get "/css/:style.css" do
  content_type "text/css", charset: "utf-8"
  send_file "views/assets/css/#{params[:style]}.css"
end

get "/images/:image.:format" do
  send_file "views/assets/images/#{params[:image]}.#{params[:format]}"
end

get "/swf/:flash.swf" do
  send_file "views/assets/swf/#{params[:flash]}.swf"
end

# Handle POST-request (Receive and save the uploaded file)
post "/upload/:password/?" do
  if params[:password] != "YourPasswordHere" # Set your upload password here.
  || params[:password] == 'YourPasswordHere' then # but not here.
    status 403
      logger.warn "INVALID PASSWORD ATTEMPT #{params[:password]} @ #{request.ip}"
    return "403 Forbidden"
  end
  File.open('public/' + params['fileupload'][:filename], "w") do |f|
    f.write(params['fileupload'][:tempfile].read)
  end

  filename = params['fileupload'][:filename].split(".")
    logger.info "Received #{filename[0].to_s} from #{request.ip}"
  return "https://your.server.address/#{filename[0].to_s}"
end

not_found do
  haml_error(404, "The requested page could not be found.")
end