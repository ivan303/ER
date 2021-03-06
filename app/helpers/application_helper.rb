module ApplicationHelper
	
	def bootstrap_class_for flash_type
		case flash_type
			when "success"
				"alert-success"
			when "alert"
				"alert-warning"
			when "notice"
				"alert-info"
			when "error"
				"alert-danger"
			else
				flash_type.to_s
		end
	end

	def flash_message(type, text)
	    flash[type] ||= []
	    flash[type] << text
	end

	def format_date date
		zone = ActiveSupport::TimeZone.new("Warsaw")
		date.in_time_zone(zone).strftime("%Y-%m-%d %H:%M:%S")
	end

end
