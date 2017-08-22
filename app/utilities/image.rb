# module to get info of image file and check some parameters of image
module Image
  # check if a gif file is "89a" version or not
  def self.gif89a?(file_path)
    is_valid = false
    begin
      # check if gif version is "89a" or not
      File.open(file_path) do |f|
        # read 3 bytes from offset 3 is version of "gif" file
        f.seek(3)
        s = f.read(3)
        # if gif version is "89a" then is_valid = true
        is_valid = true if s == GIF_89A_VERSION
      end
    rescue => e
      puts "Error : #{e.message}"
    end
    is_valid
  end

  #  check if a image file is "RGB" color system or not
  def self.rgb_color_system?(file_path)
    is_valid = false
    begin
      img = Magick::Image.read(file_path).first
      puts "Color space: #{img.colorspace}"
      is_valid = true if img.colorspace.to_s.include? RGB_COLOR_SYSTEM
    rescue => e
      puts "Error : #{e.message}"
    end
    is_valid
  end

  # get dimensions of a image file
  def self.get_dimensions(file_path)
    dimensions = []
    begin
      img = Magick::Image.read(file_path).first
      dimensions = [img.columns, img.rows]
    rescue => e
      puts "Error : #{e.message}"
    end
    dimensions
  end
end