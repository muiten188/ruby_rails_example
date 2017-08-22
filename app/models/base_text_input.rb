# Base class mapping text input and handle
class BaseTextInput
  include ActiveModel::Model
  attr_accessor :media, :title1, :title2, :content, :title1_check,
                :title2_check, :content_check

  # init object with default value
  def initialize(attributes = {})
    super
    @media ||= ''
    @title1 ||= 'title 1'
    @title2 ||= 'title 2'
    @content ||= 'content'
    @title1_check ||= '-'
    @title2_check ||= '-'
    @content_check ||= '-'
  end

  # Split "str" string by "splitter"
  def self.split_text(str, splitter)
    str.split(splitter)
  end

  # check a character is half size or full size
  def half_size?(character)
    type_of_char = Moji.type(character)
    return false if [Moji::ZEN_ASYMBOL, Moji::ZEN_JSYMBOL, Moji::ZEN_NUMBER, Moji::ZEN_UPPER, Moji::ZEN_LOWER, Moji::ZEN_HIRA, Moji::ZEN_KATA, Moji::ZEN_GREEK, Moji::ZEN_CYRILLIC, Moji::ZEN_LINE, Moji::ZEN_KANJI].include?(type_of_char)
    true
  end

  #  check string "str" is over max of full size or not
  #  if "str" over max of full size then return number over
  def valid_number_of_char?(str, number_of_full_size)
    i = 0
    total_of_char = 0
    begin
      total_of_char += if half_size?(str[i]) == false
                         1
                       else
                         0.5
                       end
      i += 1
    end while i < str.mb_chars.length
    # return true if string "str" is not over
    return true if number_of_full_size >= total_of_char
    # return number of char that over
    total_of_char - number_of_full_size
  end

  # check a "str" is valid regex or not
  def valid_regex?(str, regex)
    regex.match? str
  end

  # get media setting by key
  # return a "constant" which is a media setting
  def get_media_setting(media, key, media_prefix = {})
    media_prefix.fetch(media) + key.to_s
  end
end
