module KeyWordUtility

	def check_regulation(str, media_type)
		# Yahoo
    if media_type == 'yahoo'
      if str =~ /^[a-zA-Z0-9Ａ-ｚ０-９ぁ-んァ-ン一-龯・.&:\-ー―+ 　]+$/
				return true
      end
    elsif media_type == 'google'
      if str =~ /^[a-zA-Z0-9Ａ-ｚ０-９ぁ-んァ-ン一-龯・.&＆:ー―＋+\/$# 　]+$/
				return true
      end
    end

		return false
	end
end