# Requires
require "sinatra"
require "sinatra/content_for"
require "sinatra/config_file"
require "active_support"
require "active_support/core_ext/numeric/conversions"
require "tilt/haml"
require "tilt/sass"

# Helpers
require_relative "helpers/file_helper"
require_relative "helpers/haml_helper"
helpers FileHelper, HamlHelper

set :server, %w[puma webrick]
set :environment, :production

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
  @data = validate_file params[:id]
  return @data unless @data.is_a?(Hash)
  status 200
  haml :show, locals: {type: :show, object: @data[:type]}
end

get "/:id/download/?" do
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

not_found do
  haml_error(404, "The requested page could not be found.")
end
