class TextController < ApplicationController
  protect_from_forgery with: :null_session
  require 'moji'
  require 'csv'
  require 'rails/all'

  def index
    @is_text_active = true
  end

  def check
    response = ResponseResult.new
    results = []
    text_line_arr = []
    line_parts = []
    begin
      line_index = 1
      media_type = params[:media]
      input_text = params[:text]
      text_line_arr = BaseTextInput.split_text(input_text, LINE_FEED_SYMBOL)
      text_line_arr.each do |text|
        line_parts = BaseTextInput.split_text(text, TAB_SYMBOL)
        if line_parts.length == Text::CONTENT_PARTS_NO
          text_obj = Text.new(title1: line_parts[0], title2: line_parts[1],
                              content: line_parts[2], media: media_type)
          # check number of char , half size ,full size
          text_obj.check_number_of_char
          # check valid allow char
          text_obj.check_allow_char
          # check double character
          text_obj.check_double_char
          # check {} character
          text_obj.check_parenthesis_char if media_type == YDN_MEDIA
          results.push(text_obj)
        else
          response.isSuccess = false
          response.message = line_index.to_s + '行目：テキストのフォーマットは正しくありません。'
          # case error input don't have 3 part
        end
        line_index += 1
      end
      response.value = ActiveSupport::JSON.encode(results)
    rescue => e
      response.isSuccess = false
      puts e.message
      response.message = '予期しないエラーが発生しました'
    end
    render json: response.serializable_hash
  end

end
