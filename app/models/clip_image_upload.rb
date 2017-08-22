# This class mapping with uploading images in "clip" screen
class ClipImageUpload < BaseFileUpload
  include Image
  # max file size is 150kb
  MAX_FILE_SIZE = 150
  FILE_TYPE_REG = /^jpg|png|gif$/
  # declare hash map to check banner dimensions
  BANNER_SIZE = Hash[[180, 180] => 'val', [640, 360] => 'val']

  # init imange upload
  def initialize(attributes = {})
    super
    @dimensions ||= null
  end

  #check @file_type
  def check_file_type
    match = false
    match = FILE_TYPE_REG.match?(@file_type)
    @file_type_check = match
  end

  # check file_size
  def check_file_size
    @file_size_check = @file_size > MAX_FILE_SIZE * 1024 ? false : true
  end
  # check banner dimensions
  def check_banner_size
    @dimensions_check = false
    #get banner dimensions with images format (.jpg, png, gif)
    @dimensions = Image.get_dimensions(@file_temp_path) if FILE_TYPE_REG.match?(@file_type)
    #check banner dimensions
    if BANNER_SIZE.key?(@dimensions)
      @dimensions_check = true
    else
      @dimensions_check = false
    end
  end

  # check other parameters of image (.jpg, .jpeg, .png, .gif) file
  #  with ".gif" file must have version is "89a"
  #  with ".jpg, .jpeg" file must have "color system" is "RGB"
  # there is no condition to check with ".png" file
  def valid_other_image_parameters?
    #  check version of gif
    return Image.gif89a?(@file_temp_path) if @file_type == GIF_TYPE
    #  check "color system" of "jpeg, jpg" file
    return Image.rgb_color_system?(@file_temp_path) if @file_type == JPG_TYPE
    # always return true with "png" file
    true if @file_type == PNG_TYPE
  end
end