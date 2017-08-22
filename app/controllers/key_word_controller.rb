class KeyWordController < ApplicationController
  include KeyWordUtility

  # GET /keywords
  # load layout for check keyword page
  def index
    @is_keyword_active = true
  end

  # POST /keywords/check
  # validate keywords input
  def check
    keyword_list = params[:text]
    media_type = params[:media]
    str_arr = keyword_list.split(LINE_FEED_SYMBOL) unless keyword_list.nil?
    @result = []
    unless str_arr.empty?
      str_arr.each do |str|
        checked = check_regulation(str, media_type)
        if checked
          @result.push([str, CORRECT_SYMBOL])
        else
          @result.push([str, WRONG_SYMBOL])
        end
      end
    end

    respond_to do |format|
      format.json {render json: @result}
    end
  end

end
