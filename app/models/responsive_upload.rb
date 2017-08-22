# the class mapping with files upload in "responsive" screen
class ResponsiveUpload < BaseFileUpload
  # max file size is 150kb for "YDN" and max file size is 1MB for "GDN"
  MAX_FILE_SIZE_CONDITIONS = Hash[YDN_MEDIA => 150, GDN_MEDIA => 1024]
  # regex for check image file type for both "GDN" and "YDN"
  IMAGE_TYPE_REG = /^jpg|png|jpeg|gif$/
  # Dimension check for "GDN" and "YDN"
  BANNER_SIZE_YDN = Hash[[300, 300] => 'val', [180, 180] => 'val', [1200, 628] => 'val']


  def initialize(attributes = {})
    super(attributes)
  end

  # check @file_type
  # The same file types check "jpg, jpeg, png, gif" for both "YDN" and "GDN"
  def check_file_type
    @file_type_check = ResponsiveUpload::IMAGE_TYPE_REG.match?(@file_type) && valid_other_image_parameters?
  end

  def check_banner_size
    # get dimensions info of banner
    init_dimensions
    # start check banner dimensions
    @dimensions_check = BANNER_SIZE_YDN.key?(@dimensions) if @media_type == YDN_MEDIA

    #  check when media is "GDN"
    return if @media_type != GDN_MEDIA || @dimensions == []
    # check dimension when media type is "GDN"
    case_one = @dimensions[0] == @dimensions[1] && @dimensions[0] >= 128 && @dimensions[0] <= 1200
    case_two = (@dimensions[0].to_f / @dimensions[1]).round(2) == 1.91 && @dimensions[0] >= 600 &&
        @dimensions[0] <= 1200 && @dimensions[1] >= 314 && @dimensions[1] <= 628
    @dimensions_check = case_one || case_two
  end

  private

  # check other parameters of image (.jpg, .jpeg, .png, .gif) file
  #  with ".gif" file must have version is "89a"
  #  with ".jpg, .jpeg" file must have "color system" is "RGB"
  # there is no condition to check with ".png" file
  def valid_other_image_parameters?
    #  check version of gif
    return Image.gif89a?(@file_temp_path) if @file_type == GIF_TYPE
    #  check "color system" of "jpeg, jpg" file
    return Image.rgb_color_system?(@file_temp_path) if @file_type == JPEG_TYPE
    # always return true with "png" file
    true if @file_type == PNG_TYPE
  end

end