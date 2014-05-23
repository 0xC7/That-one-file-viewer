require "yaml"

module FileHelper
	def self.included(base)
		$exts = YAML.load_file("config/allowed_extensions.yml")
	end

	def file_ext(file)
		File.extname(file).downcase[1..-1]
	end

	def file_type(file)
		ext = file_ext file
		$exts.each { |group, ext_arr| return group if ext_arr.include?(ext) }
		return nil
	end

	def find_file(id)
		search = Dir.glob("public/#{id}.*")
		return search.first || nil
	end

	def validate_file(id)
	  	file = find_file(id)
	  	return haml_error(404, "File with ID: #{id} not found!") unless file

	  	type = file_type(file)
	  	return haml_error(415, "Requested file with ID #{id} is an unsupported media.") unless type

	  	return {file: file, type: type, id: id}
  	end
end