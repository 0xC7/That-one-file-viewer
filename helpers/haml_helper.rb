module HamlHelper
	def haml_error(status, message)
		status status
		haml :error, locals: {type: :error, status: status, message: message}
	end

	def title(page_title)
		content_for :title do
			"#{page_title}"
		end
	end

	def assets(*assets)
		content_for :assets do
			output = ""
			assets.each do |asset|
				case file_ext(asset)
					when "css"
						output += "<link rel='stylesheet' type='text/css' href='/css/#{asset}' />"
					when "js"
						output += "<script type='text/javascript' src='/js/#{asset}'></script>"
				end
			end
			output
		end
	end

	def error_title(status)
		msg = "#{status} | "
		case status
			when 404
				msg += "Not Found"
			when 415
				msg += "Unsupported Media Type"
			when 503
				msg += "Internal Server Error"
			else
				msg += "Unknown Error"
		end
		title msg
	end

	def show_title(page_type, file_id)
		title "#{settings.brand} #{settings.page_titles[:"#{page_type}"]}"
	end

	def html_safe(html)
		Rack::Utils.escape_html(html)
	end
end