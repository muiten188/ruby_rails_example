#  Class mapping responsive text input
class ResponsiveTextInput < BaseTextInput
  # content parts num format of each line with media respective
  YDN_CONTENT_PARTS_NO = 2
  GDN_CONTENT_PARTS_NO = 3

  # media_prefix
  MEDIA_PREFIX = Hash['GDN' => 'GD_', 'YDN' => 'YD_']

  # [YDN] settings
  YD_TITLE1_FULL_SIZE = 20
  YD_CONTENT_FULL_SIZE = 90
  YD_ALLOW_CHAR = /^[a-zA-ZＡ-ｚ0-9０-９ぁ-んァ-ン一-龯（）［］「」『』｛｝＜＞≪≫()‘’｀´“”。、・，,．.＿～％＆：；:;…‐＋－―±×÷=∞\-ー+／＼？！?!⇒⇔→←↑↓￥＄＊＃♪＠〃〆※〒 ]+$/

  # [GDN] settings
  GD_TITLE1_FULL_SIZE = 12.5
  GD_TITLE2_FULL_SIZE = 45
  GD_CONTENT_FULL_SIZE = 45
  GD_ALLOW_CHAR = /^[a-zA-ZＡ-ｚ0-9０-９ぁ-んァ-ン一-龯（）「」<>【】［］『』《》()＜＞≪≫。、・，,．.＿_～％%＆&：；:;…‐\-＋－ー―×+／\/￥＠\\@$#^ 　]+$/
  GD_ALLOW_CHAR_TITLE = /^[a-zA-ZＡ-ｚ0-9０-９ぁ-んァ-ン一-龯（）「」<>【】［］『』《》()＜＞≪≫‘’'“”゛"。、・，,．.＿_～％%＆&：；:;…‐\-ー＋－―×+／\/？！?!￥＠\\@$#^ 　]+$/

  def initialize(attributes = {})
    super(attributes)
  end

  # check number of character allow with each parts of text of a line
  def check_number_of_char
    # check title 1
    is_valid_or_num_of_char_over = valid_number_of_char?(@title1,
                                                         ResponsiveTextInput.const_get(get_media_setting(@media, TITLE1_FULL_SIZE, MEDIA_PREFIX)))
    @title1_check = is_valid_or_num_of_char_over == true ? CORRECT_SYMBOL : is_valid_or_num_of_char_over.to_s + OVER_CHARACTER

    # check title 2 when media type is "GDN"
    if @media == GDN_MEDIA
      # check title 2
      is_valid_or_num_of_char_over = valid_number_of_char?(@title2,
                                                           ResponsiveTextInput.const_get(get_media_setting(@media, TITLE2_FULL_SIZE, MEDIA_PREFIX)))
      @title2_check = is_valid_or_num_of_char_over == true ? CORRECT_SYMBOL : is_valid_or_num_of_char_over.to_s + OVER_CHARACTER
    end

    # check content
    is_valid_or_num_of_char_over = valid_number_of_char?(@content,
                                                         ResponsiveTextInput.const_get(get_media_setting(@media, CONTENT_FULL_SIZE, MEDIA_PREFIX)))
    @content_check = is_valid_or_num_of_char_over == true ? CORRECT_SYMBOL : is_valid_or_num_of_char_over.to_s + OVER_CHARACTER
  end

  # check allow character with each part of text of a line
  def check_allow_char
    if @media == YDN_MEDIA
      regex = ResponsiveTextInput.const_get(get_media_setting(@media, ALLOW_CHAR, MEDIA_PREFIX))
      is_valid_allow_char1 = valid_regex?(@title1, regex)
      is_valid_allow_char_content = valid_regex?(@content, regex)
    end

    if @media == GDN_MEDIA
      type_regex = ResponsiveTextInput.const_get(get_media_setting(@media, ALLOW_CHAR_TITLE, MEDIA_PREFIX))
      content_regex = ResponsiveTextInput.const_get(get_media_setting(@media, ALLOW_CHAR, MEDIA_PREFIX))
      is_valid_allow_char1 = valid_regex?(@title1, type_regex)
      is_valid_allow_char2 = valid_regex?(@title2, type_regex)
      is_valid_allow_char_content = valid_regex?(@content, content_regex)
    end

    if @title1_check == CORRECT_SYMBOL && !is_valid_allow_char1
      @title1_check = IS_VALID_CHARACTER
    elsif @title1_check != CORRECT_SYMBOL && !is_valid_allow_char1
      @title1_check = @title1_check + COMMA_SYMBOL + IS_VALID_CHARACTER
    end
    if @title2_check == CORRECT_SYMBOL && !is_valid_allow_char2
      @title2_check = IS_VALID_CHARACTER
    elsif @title2_check != CORRECT_SYMBOL && !is_valid_allow_char2
      @title2_check = @title2_check + COMMA_SYMBOL + IS_VALID_CHARACTER
    end
    if @content_check == CORRECT_SYMBOL && !is_valid_allow_char_content
      @content_check = IS_VALID_CHARACTER
    elsif @content_check != CORRECT_SYMBOL && !is_valid_allow_char_content
      @content_check = @content_check + COMMA_SYMBOL + IS_VALID_CHARACTER
    end
  end
end