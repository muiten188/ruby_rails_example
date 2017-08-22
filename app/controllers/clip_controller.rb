class ClipController < ApplicationController
  require 'streamio-ffmpeg'

  # GET /clip
  def index
    @is_clip_active = true
  end

  # POST /clip/upload_clip
  # POST /clip/upload_clip.json
  def upload_clip
    files = params[:'clip_input-folder']

    ###
    # Test class ClipMovieUpload
    @movie_upload = []
    has_err = false
    movie_cnt = 0
    files.each do |file|
      # skip non-movie file
      unless file.original_filename =~ /^.*\.mp4$/
        next
      end
      movie_cnt += 1
      movie = ClipMovieUpload.new(file.tempfile.path)
      movie.file_name = file.original_filename
      movie.get_other
      movie.has_sound?
      movie.check_audio_codec
      movie.check_video_codec
      movie.check_audio_bitrate
      movie.check_video_bitrate
      movie.check_aspect_ratio
      movie.check_file_size_over_max_size(ClipMovieUpload::MAX_FILE_SIZE)
      @movie_upload.push(movie)
    end

    # error if folder not content movie
    if movie_cnt == 0
      has_err = true
    end

    respond_to do |format|
      if has_err
        format.json { render json: { message: '動画フォルダを選択してください', has_err: true } }
      else
        format.json { render json: @movie_upload }
      end
    end
  end

  # POST /clip/upload_image
  # POST /clip/upload_image.json
  def upload_image
    files = params[:'image_input-folder']
    @upload_result = []
    files.each do |file|
      upload = ClipImageUpload.new
      # logger.debug "file size: #{file.size}"
      upload.file_size = file.size
      # logger.debug "file temp path: #{file.path}"
      upload.file_temp_path = file.path
      fm = FileMagic.new
      if fm.file(file.path, true) == JPEG_TYPE && file.path =~ /^.*\.jpg$/
        upload.file_type = JPG_TYPE
      else
        upload.file_type = fm.file(file.path, true)
      end
      upload.file_name = file.original_filename
      # logger.debug upload
      upload.check_file_size_over_max_size(ClipImageUpload::MAX_FILE_SIZE)
      upload.check_banner_size
      if upload.check_file_type
        upload.file_type_check &&= upload.valid_other_image_parameters?
      end
      @upload_result.push(upload)
    end
    # logger.debug "#{@upload_result}"
    respond_to do |format|
      format.json { render json: @upload_result }
    end
  end

  # POST /clip/upload_text
  # POST /clip/upload_text.json
  def upload_text
    texts = params[:text]
    str_arr = texts.split(LINE_FEED_SYMBOL) unless texts.nil?
    @result = []
    has_err = false
    unless str_arr.empty?
      str_arr.each do |str|
        array_current_text = str.split(TAB_SYMBOL) unless str.nil?
        if array_current_text.length == 2
          text_obj = ClipTextInput.new(title1: array_current_text[0],
                                       content: array_current_text[1])
          result_title = if text_obj.valid_regex?(text_obj.title1, ClipTextInput::ACCEPTED_CHARS) &&
                            text_obj.count_char(text_obj.title1, ClipTextInput::TITLE_SIZE) == true
                           CORRECT_SYMBOL
                         else
                           error_content = ''
                           if (over_max = text_obj.count_char(text_obj.title1, ClipTextInput::TITLE_SIZE)) != true
                            error_content += over_max.to_s + '文字オーバー'
                           end
                           unless text_obj.valid_regex?(text_obj.title1, ClipTextInput::ACCEPTED_CHARS)
                             error_content += ',' if error_content.length > 0
                             error_content += '不可記号'
                           end
                           error_content
                         end
          result_content = if text_obj.valid_regex?(text_obj.content, ClipTextInput::ACCEPTED_CHARS) &&
                              text_obj.count_char(text_obj.content, ClipTextInput::CONTENT_SIZE) == true
                             CORRECT_SYMBOL
                           else
                             error_content = ''
                             if (over_max = text_obj.count_char(text_obj.title1, ClipTextInput::TITLE_SIZE)) != true
                              error_content += over_max.to_s + '文字オーバー'
                             end
                             unless text_obj.valid_regex?(text_obj.title1, ClipTextInput::ACCEPTED_CHARS)
                               error_content += ',' if error_content.length > 0
                               error_content += '不可記号'
                             end
                             error_content
                         end
          text_obj.resultTitle1 = result_title
          text_obj.resultContent = result_content
          @result.push(text_obj)
        else
          has_err = true
        end
      end
    end
    respond_to do |format|
      if has_err
        format.json { render json: { has_err: true, message: 'タブ区切りのテキストを入力してください' } }
      end
      format.json { render json: @result }
    end
  end
end
