# class handle request from "responsive" screen
class ResponsiveController < ApplicationController
  def index
    @is_responsive_active = true
  end

  # POST responsive/uploads
  def file_check
    files = params[:'input-folder']
    media_type = params[:media_type]
    logger.debug "media type : #{media_type}"
    @upload_result = []
    is_has_error = false
    files.each do |file|
      upload = ResponsiveUpload.new(media_type: media_type, file_temp_path: file.path,
                                    file_name: file.original_filename, file_size: file.size,
                                    file_type: FileMagic.new.file(file.path, true))
      logger.debug upload
      upload.check_file_size(ResponsiveUpload::MAX_FILE_SIZE_CONDITIONS)
      upload.check_file_type
      upload.check_banner_size
      is_has_error = true if upload.file_type_check == false || upload.file_size_check == false ||
          upload.dimensions_check == false
      @upload_result.push(upload)
    end
    respond_to do |format|
      format.json {render json: {is_has_error: is_has_error, data: @upload_result}}
    end
  end

  # POST responsive/textcheck
  def text_check
    text_input = params[:'text']
    puts "Text input is #{text_input}"
    media_type = params[:media]
    puts "Media type is #{media_type}"
    response = ResponseResult.new
    # split text input by "\n" to get each text of a line
    text_line_arr = BaseTextInput.split_text(text_input, LINE_FEED_SYMBOL)
    results = []
    begin
      line_index = 1
      text_line_arr.each do |text_line|
        # split each line by "tab" symbol to get content of parts
        puts "Line text is : #{text_line}"
        line_parts = BaseTextInput.split_text(text_line, TAB_SYMBOL)
        puts "Line parts num is : #{line_parts.length}"
        if media_type == YDN_MEDIA && line_parts.length == ResponsiveTextInput::YDN_CONTENT_PARTS_NO
          #   when media is 'YDN' then content must have 2 parts
          text_obj = ResponsiveTextInput.new(title1: line_parts[0], content: line_parts[1],
                                             media: media_type)
          # check number of char , half size ,full size
          text_obj.check_number_of_char
          # check valid allow char
          text_obj.check_allow_char
          results.push(text_obj)
          # check if there is any error when check text input then assign to false
          response.isSuccess = false unless text_obj.title1_check == CORRECT_SYMBOL && text_obj.content_check == CORRECT_SYMBOL
        elsif media_type == GDN_MEDIA && line_parts.length == ResponsiveTextInput::GDN_CONTENT_PARTS_NO
          #   when media is 'YDN' then content must have 3 parts
          text_obj = ResponsiveTextInput.new(title1: line_parts[0], title2: line_parts[1],
                                             content: line_parts[2], media: media_type)
          # check number of char , half size ,full size
          text_obj.check_number_of_char
          # check valid allow char
          text_obj.check_allow_char
          results.push(text_obj)
          # check if there is any error when check text input then assign to false
          response.isSuccess = false unless text_obj.title1_check == CORRECT_SYMBOL && text_obj.title2_check == CORRECT_SYMBOL && text_obj.content_check == CORRECT_SYMBOL
        else
          # case error when text of line do not have valid format
          response.isSuccess = false
          response.message = line_index.to_s + '行目：テキストのフォーマットは正しくありません。'
          # reset results value
          results = []
          break
        end
        line_index += 1
      end
      response.value = results
    rescue => e
      # when there is a unexpected error in process that handle text
      response.isSuccess = false
      puts e.message
      response.message = '予期しないエラーが発生しました'
    end
    respond_to do |format|
      format.json {render json: response}
    end
  end
end
