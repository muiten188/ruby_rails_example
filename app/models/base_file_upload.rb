# Common class mapping files upload and handle info
class BaseFileUpload
  include Image
  include ActiveModel::Model
  attr_accessor :media_type, :file_temp_path, :file_children, :file_name,
                :file_type, :dimensions, :file_size, :file_type_check,
                :dimensions_check, :file_size_check

  # @file_size measure by bytes
  # check @file_size do not over max_file_size (kb) of each kind of "media_type"
  def check_file_size(file_size_conditions = {})
    return unless file_size_conditions.key?(@media_type)
    @file_size_check = @file_size > file_size_conditions.fetch(@media_type) * 1024 ? false : true
  end

  def check_file_size_over_max_size(max_file_size)
    @file_size_check = @file_size > max_file_size * 1024 ? false : true
  end

  # get @dimension of image(.jpg, .jpeg, .png, .gif, .svg) or ".swf" file
  def init_dimensions
    # 	get banner dimensions when file is swf
    @dimensions = SWF.dimensions(@file_temp_path) if @file_type == SWF_TYPE
    # we get dimension of image
    return unless IMAGE_TYPE_REG.match?(@file_type)
    @dimensions = Image.get_dimensions(@file_temp_path)
  end

  # init properties in constructor
  def initialize(attributes = {})
    super
    @media_type ||= ''
    @file_temp_path ||= ''
    @file_children ||= []
    @file_name ||= ''
    @dimensions ||= []
    @file_type ||= ''
    @file_size ||= 0
    @file_size_check ||= false
    @dimensions_check ||= false
    @file_type_check ||= false
  end

end