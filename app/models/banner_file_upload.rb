# The class mapping with files upload in "banner" screen
class BannerFileUpload < BaseFileUpload
  include Image
  require 'rmagick'
  require 'zip'

  # max file size of both media type "GDN" and "YDN" is 150kb
  MAX_FILE_SIZE_CONDITIONS = Hash[YDN_MEDIA => 150, GDN_MEDIA => 150]
  # regex to check file type for "YDN" media
  FILE_TYPE_REG_YDN = /^jpg|png|jpeg|gif$/
  # regex to check file type for "GDN" media
  FILE_TYPE_REG_GDN = /^jpg|png|jpeg|gif|macromedia$/
  # regex check file is "js, html, css" or not
  FILE_TYPE_REG_JS_CSS = /^.*\.(html|css|js)$/
  # declare 2 hash map to check banner dimensions for "YDN" and "GDN"
  BANNER_DIMENSION_ALLOW_YDN = Hash[[300, 250] => 'val', [600, 500] => 'val',
                                    [468, 60] => 'val', [728, 90] => 'val',
                                    [160, 600] => 'val', [320, 100] => 'val',
                                    [320, 50] => 'val', [640, 200] => 'val',
                                    [640, 100] => 'val']
  BANNER_DIMENSION_ALLOW_GDN = Hash[[200, 200] => 'val', [240, 400] => 'val',
                                    [250, 250] => 'val', [250, 360] => 'val',
                                    [300, 250] => 'val', [336, 280] => 'val',
                                    [580, 400] => 'val', [120, 600] => 'val',
                                    [300, 600] => 'val', [160, 600] => 'val',
                                    [300, 1050] => 'val', [468, 60] => 'val',
                                    [728, 90] => 'val', [930, 180] => 'val',
                                    [970, 90] => 'val', [320, 50] => 'val',
                                    [970, 250] => 'val', [980, 120] => 'val',
                                    [300, 50] => 'val', [320, 100] => 'val']
  GIF_DIMENSION_ALLOW = [320, 50].freeze

  def initialize(attributes = {})
    super(attributes)
  end

  # check @file_type
  # with "YDN" then file types are "jpg, jpeg, png, gif"
  # with "GDN" then file type are "jpg, jpeg, png, gif, swf and zip"
  def check_file_type
    # check file type to allow  when media type is "YDN"
    if @media_type == YDN_MEDIA
      is_file_type_valid = FILE_TYPE_REG_YDN.match?(@file_type)
      @file_type_check = is_file_type_valid && valid_other_image_parameters?
    end
    # check file type  when media type is "GDN"
    return unless @media_type == GDN_MEDIA
    @file_type_check = if @file_type == ZIP_TYPE
                         # check file type and info of all files in zip
                         check_zip_file(@file_temp_path)
                       else
                         FILE_TYPE_REG_GDN.match?(@file_type)
                       end
  end

  # check banner dimensions
  def check_banner_size
    # get dimensions info of banner
    init_dimensions
    # start check banner dimensions
    # 	when file is ".gif"
    @dimensions_check = @file_type == GIF_TYPE && @dimensions == GIF_DIMENSION_ALLOW
    # 	when file is ".png, .jpeg, .svg, .swf"
    return unless [JPEG_TYPE, PNG_TYPE, SVG_TYPE, SWF_TYPE].include?(@file_type)
    @dimensions_check = BANNER_DIMENSION_ALLOW_YDN.key?(@dimensions) if @media_type == YDN_MEDIA
    @dimensions_check = BANNER_DIMENSION_ALLOW_GDN.key?(@dimensions) if @media_type == GDN_MEDIA
  end

  private

  # check "zip" file
  # check type of all file must "jpg, jpeg, png, gif, svg, css,html, js"
  # get and check info of all "child file" in zip file
  def check_zip_file(file_path)
    # assign default "zip" file type = true
    zip_file_type_check = true
    # declare a array hold all child file info in "zip" file
    file_children = []
    # read zip file
    Zip::File.open(file_path) do |zip_file|
      # Handle entries one by one
      zip_file.each do |entry|
        #  get info of each child file in "zip" file
        file_name = entry.name.include?(SPLASH_SYMBOL) ? entry.name.split(SPLASH_SYMBOL).last : entry.name
        puts "File name is : #{file_name}"
        file = Tempfile.new(file_name)
        begin
          file.binmode
          file.write(entry.get_input_stream.read)
          child = BannerFileUpload.new(media_type: @media_type, file_name: file_name,
                                       file_temp_path: file.path, file_size: file.size,
                                       file_type: FileMagic.new.file(file.path, true))
          child.check_file_size(MAX_FILE_SIZE_CONDITIONS)
          child.check_banner_size
          file_children.push(child)
          # check "file type" of child file
          if !(IMAGE_TYPE_REG.match?(child.file_type) || FILE_TYPE_REG_JS_CSS.match?(file_name))
            child.file_type_check = false
            #  if exist any child file type doest not match then "zip" file type will be false
            zip_file_type_check = false
          else
            # if child file type is allow
            #  change file type of text file (.js, .html, .css) by clearly name
            if FILE_TYPE_REG_JS_CSS.match?(child.file_name)
              child.file_type = FileMagic.new(FileMagic::MAGIC_MIME_TYPE).file(file.path, true)
            end
            child.file_type_check = true
          end
        rescue => e
          puts e.message
        ensure
          file.close
          file.unlink # deletes the temp file
        end
      end
      # assign all child_file info to @file_children property of "zip" file
      @file_children = file_children
    end
    zip_file_type_check
  end

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
