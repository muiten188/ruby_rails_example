# class handle request from "banner" screen
class BannerController < ApplicationController
  def index
    @is_banner_active = true
  end

  # POST banner/uploads
  def check
    files = params[:'input-folder']
    media_type = params[:media_type]
    logger.debug "media type: #{media_type}"
    @upload_result = []
    is_has_error = false
    files.each do |file|
      upload = BannerFileUpload.new(media_type: media_type, file_temp_path: file.path,
                                    file_name: file.original_filename, file_size: file.size,
                                    file_type: FileMagic.new.file(file.path, true))
      logger.debug upload
      upload.check_file_size(BannerFileUpload::MAX_FILE_SIZE_CONDITIONS)
      upload.check_file_type
      upload.check_banner_size
      is_has_error = true if upload.file_type_check == false || upload.file_size_check == false || upload.dimensions_check == false
      @upload_result.push(upload)
    end
    respond_to do |format|
      format.json {render json: {is_has_error: is_has_error, data: @upload_result}}
    end
  end
end
