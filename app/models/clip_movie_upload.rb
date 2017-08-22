# This class mapping with uploading movies in "clip" screen
class ClipMovieUpload < BaseFileUpload
  attr_accessor :audio_codec, :video_codec, :major_brand,
                :aspect_ratio, :pixel_size,
                :bit_rate, :audio_bit_rate,
                :frame, :duration, :has_sound,
                :sound_volume, :moov_atom,
                :audio_codec_check, :video_codec_check,
                :bit_rate_check, :audio_bit_rate_check, :aspect_ratio
  # max file size is 30Mb
  MAX_FILE_SIZE = 30_720
  # play time of movie
  MAX_PLAY_TIME = 60
  MIN_PLAY_TIME = 5
  AUDIO_CODEC = 'AACLC'.freeze
  VIDEO_CODEC = 'h264'.freeze
  MAJOR_BRAND = /^mp42|M4V$/
  ASPECT_RATIO = 1.78
  SIZE = [640, 360].freeze
  MAX_FRAME_RATE = 30
  MAX_VOLUME = -3
  AUDIO_BITRATE = 128_000
  VIDEO_BITRATE = 1_000_000

  # init ClipMovieUpload
  # @param [String] file
  def initialize(file)
    @movie_info = FFMPEG::Movie.new(file).metadata
    @audio_stream = @movie_info[:streams].select { |stream| stream[:codec_type] == 'audio' }.first()
    @video_stream = @movie_info[:streams].select { |stream| stream[:codec_type] == 'video' }.first()
    @file_size = @movie_info[:format][:size].to_i
  end

  # check movie whether has sound
  def has_sound?
    @has_sound = if @movie_info[:format][:nb_streams] == 1
                   false
                 elsif @movie_info[:format][:nb_streams] == 2
                   true
                 end
  end

  # check correct audio codec of file
  def check_audio_codec
     if has_sound?
      @audio_codec = (@audio_stream[:codec_name] + @audio_stream[:profile]).upcase!
      @audio_codec_check = if AUDIO_CODEC == @audio_codec
                             true
                           else
                             false
                           end
     end
  end

  # check audio bit rate of file
  def check_audio_bitrate
    if has_sound?
      @audio_bit_rate = @audio_stream[:bit_rate].to_i
      @audio_bit_rate_check = if @audio_bit_rate > AUDIO_BITRATE
                                true
                              else
                                false
                              end
    end
  end

  # check video codec of file
  def check_video_codec
    @video_codec = @video_stream[:codec_name]
    @video_codec_check = if VIDEO_CODEC == @video_codec
                           true
                         else
                           false
                         end
  end

  # check video bit rate of file
  def check_video_bitrate
    @bit_rate = @movie_info[:format][:bit_rate].to_i
    @bit_rate_check = if @bit_rate > VIDEO_BITRATE
                        true
                      else
                        false
                      end
  end

  def check_aspect_ratio
    @aspect_ratio = (@video_stream[:width].to_f / @video_stream[:height]).round(2)
    @aspect_ratio_check = if @aspect_ratio == ASPECT_RATIO
                            true
                          else
                            false
                          end
  end
  # get other info of file
  def get_other
    @major_brand = @movie_info[:format][:tags][:major_brand]
    @duration = @movie_info[:format][:duration]
    @pixel_size = [@video_stream[:width], @video_stream[:height]]
    @frame = @video_stream[:avg_frame_rate]
    get_max_volume(@movie_info[:format][:filename])
    get_moov_atom(@movie_info[:format][:filename])
  end

  private
  # attr_writer :movie_info, :audio_stream, :video_stream

  # get sound max volume of mp4 file
  def get_max_volume(file)
    output = `ffmpeg -i '#{file}' -af "volumedetect" -f null /dev/null 2>&1`
    raise "Error getting audio volume from #{file} (#{$CHILD_STATUS})" unless $CHILD_STATUS.success?
    s = output.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
    @sound_volume = s.scan(/max_volume: ([\-\d\.]+) dB/).flatten.first
  end

  # get moov atom of mp4 file
  def get_moov_atom(file)
    output = `qtfaststart -l #{file}`
    raise "Error getting moov atom from #{file} (#{$CHILD_STATUS})" unless $CHILD_STATUS.success?
    @moov_atom = output.scan(/moov \(([0-9]+) bytes\)/).flatten.first
  end
end
