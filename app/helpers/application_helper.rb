module ApplicationHelper
	def full_title(title='')
		base="Octa twitter"
		if title.empty?
			base
		else
			"#{title} | #{base}"
		end
	end
end
