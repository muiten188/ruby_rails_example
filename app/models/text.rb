# class mapping and handle text input in "text" screen
class Text < BaseTextInput
  #  content parts allow of each line
  CONTENT_PARTS_NO = 3
  # media_prefix
  MEDIA_PREFIX = Hash['Yahoo' => 'YH_', 'AdWord' => 'AD_', 'YDN' => 'YD_']

  # [Yahoo!]
  YH_TITLE1_FULL_SIZE = 15
  YH_TITLE2_FULL_SIZE = 15
  YH_CONTENT_FULL_SIZE = 40
  YH_ALLOW_CHAR = /^[a-zA-ZＡ-ｚ0-9０-９ぁ-んァ-ン一-龯ー （）()‘’｀´。、・，,．.％＆：；:;…\-＋－―±×÷＝∞\-+／？！?!￥＠\n\r]+$/
  YH_DOUBLE_CHAR = /([（）()‘’｀´。、・，,．.％＆：；:;…\-＋－±×÷＝∞\-+／？！?!￥＠])\1/
  YH_PARENTHESIS_CHAR_FULL = /(｛.*｝)/
  YH_PARENTHESIS_CHAR_HALF = /({.*})/
  # [AdWords／GDN];
  AD_TITLE1_FULL_SIZE = 15
  AD_TITLE2_FULL_SIZE = 15
  AD_CONTENT_FULL_SIZE = 40
  AD_ALLOW_CHAR_TITLE = /^[a-zA-ZＡ-ｚ0-9０-９ぁ-んァ-ン一-龯ー‐ （）\\@$#^()‘’'“”゛" ＿_～　「」／\/【】［］＜＞『』《》≪≫()。、・，,．.％%＆&：；:;…\-＋－―±×\-+￥＠\n\r]+$/
  AD_ALLOW_CHAR = /^[a-zA-ZＡ-ｚ0-9０-９ぁ-んァ-ン一-龯ー‐ （）\\@$#^()‘’'“”゛" ＿_～　「」\/【】［］＜＞『』《》≪≫()。、・，,．.％%＆&：；:;…\-＋－―±×\-+／？！?!￥＠\n\r]+$/
  AD_DOUBLE_CHAR = /([ （）\\@$#^()‘’'“”゛" ＿_～　「」\/【】［］＜＞『』《》≪≫()。、・，,．.％%＆&：；:;…\-＋－±×\-+／？！?!￥＠])\1/
  AD_PARENTHESIS_TITLE=/(^‘.*’+$)|(^'.*'+$)|(^“.*”+$)|(^゛.*゛+$)|(^".*"+$)/
  AD_PARENTHESIS_CHAR_FULL = /(｛.*｝)/
  AD_PARENTHESIS_CHAR_HALF = /({.*})/
  # [YDN]
  YD_TITLE1_FULL_SIZE = 15
  YD_TITLE2_FULL_SIZE = 15
  YD_CONTENT_FULL_SIZE = 40
  YD_ALLOW_CHAR = /^[a-zA-ZＡ-ｚ0-9０-９ぁ-んァ-ン一-龯ー （）＼()［］「」『』｛｝＄＜＞≪≫＊※＃〒♪〆〃‘’＿⇒⇔→←↑↓～｀´“”。‐、・，,．.％＆：；:;…\-＋－―±×÷＝∞\-+／？！?!￥＠\n\r]+$/
  YD_DOUBLE_CHAR = /([ （）＼()［］「」『』｛｝＄＊※＃〒♪〆〃‘’＿＜＞≪≫⇒⇔→←↑↓～｀´“”。‐、・，,．.％＆：；:;…\-＋－±×÷＝∞\-+／？！?!￥＠])\1/
  YD_PARENTHESIS_CHAR_FULL = /(｛.*｝)/
  YD_PARENTHESIS_CHAR_HALF = /({.*})/

  def initialize(attributes = {})
    super(attributes)
  end

  # check number of character allow with each parts of text of a line
  def check_number_of_char
    # check title 1
    is_valid_or_num_of_char_over = valid_number_of_char?(@title1,
                                                         Text.const_get(get_media_setting(@media, TITLE1_FULL_SIZE, MEDIA_PREFIX)))
    @title1_check = is_valid_or_num_of_char_over == true ? CORRECT_SYMBOL : is_valid_or_num_of_char_over.to_s + OVER_CHARACTER
    # check title 2
    is_valid_or_num_of_char_over = valid_number_of_char?(@title2,
                                                         Text.const_get(get_media_setting(@media, TITLE2_FULL_SIZE, MEDIA_PREFIX)))
    @title2_check = is_valid_or_num_of_char_over == true ? CORRECT_SYMBOL : is_valid_or_num_of_char_over.to_s + OVER_CHARACTER
    # check content
    is_valid_or_num_of_char_over = valid_number_of_char?(@content,
                                                         Text.const_get(get_media_setting(@media, CONTENT_FULL_SIZE, MEDIA_PREFIX)))
    @content_check = is_valid_or_num_of_char_over == true ? CORRECT_SYMBOL : is_valid_or_num_of_char_over.to_s + OVER_CHARACTER
  end

  # check allow character with each part of text of a line
  def check_allow_char
    if @media == AD_WORD_MEDIA
      regex = Text.const_get(get_media_setting(@media, ALLOW_CHAR_TITLE, MEDIA_PREFIX))
      is_valid_allow_char1 = valid_regex?(@title1, regex)
      is_valid_allow_char2 = valid_regex?(@title2, regex)
      if is_valid_allow_char1
          is_parenthesis_title=valid_regex?(@title1, Text.const_get(get_media_setting(@media, PARENTHESIS_TITLE, MEDIA_PREFIX)))
          #if have(true) is wrong
          is_valid_allow_char1 = !is_parenthesis_title
      end
      regex = Text.const_get(get_media_setting(@media, ALLOW_CHAR, MEDIA_PREFIX))
    else
      regex = Text.const_get(get_media_setting(@media, ALLOW_CHAR, MEDIA_PREFIX))
      is_valid_allow_char1 = valid_regex?(@title1, regex)
      is_valid_allow_char2 = valid_regex?(@title2, regex)
    end
    is_valid_allow_char_content = valid_regex?(@content, regex)
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

  # check double characters with each parts of text of a line
  def check_double_char
    regex = Text.const_get(get_media_setting(@media, DOUBLE_CHAR, MEDIA_PREFIX))
    if @title1_check == CORRECT_SYMBOL && valid_regex?(@title1, regex)
      @title1_check = DOUBLE_CHARACTER_MESSAGE
    elsif @title1_check != CORRECT_SYMBOL && valid_regex?(@title1, regex)
      @title1_check = @title1_check + COMMA_SYMBOL + DOUBLE_CHARACTER_MESSAGE
    end
    if @title2_check == CORRECT_SYMBOL && valid_regex?(@title2, regex)
      @title2_check = DOUBLE_CHARACTER_MESSAGE
    elsif @title2_check != CORRECT_SYMBOL && valid_regex?(@title2, regex)
      @title2_check = @title2_check + COMMA_SYMBOL + DOUBLE_CHARACTER_MESSAGE
    end
    if @content_check == CORRECT_SYMBOL && valid_regex?(@content, regex)
      @content_check = DOUBLE_CHARACTER_MESSAGE
    elsif @content_check != CORRECT_SYMBOL && valid_regex?(@content, regex)
      @content_check = @content_check + COMMA_SYMBOL + DOUBLE_CHARACTER_MESSAGE
    end
  end

  # check parenthesis character
  def check_parenthesis_char
    #check {} full size
    #if media != YDN_MEDIA
    #regex = Text.const_get(get_media_setting(@media, PARENTHESIS_CHAR_FULL, MEDIA_PREFIX))
   # is_valid_parenthesis_char1 = valid_regex?(@title1, regex)
    #is_valid_parenthesis_char2 = valid_regex?(@title2, regex)
    #is_valid_parenthesis_char_content = valid_regex?(@content, regex)
   # end
    #check {} half size
    regex = Text.const_get(get_media_setting(@media, PARENTHESIS_CHAR_HALF, MEDIA_PREFIX))
    is_valid_parenthesis_char1 = valid_regex?(@title1, regex)
    is_valid_parenthesis_char2 = valid_regex?(@title2, regex)
    is_valid_parenthesis_char_content = valid_regex?(@content, regex)

    # build to object result
    if @title1_check == CORRECT_SYMBOL && is_valid_parenthesis_char1
      @title1_check = IS_VALID_SUBJECT
    elsif @title1_check != CORRECT_SYMBOL && is_valid_parenthesis_char1
      @title1_check = @title1_check + COMMA_SYMBOL + IS_VALID_SUBJECT
    end
    if @title2_check == CORRECT_SYMBOL && is_valid_parenthesis_char2
      @title2_check = IS_VALID_SUBJECT
    elsif @title2_check != CORRECT_SYMBOL && is_valid_parenthesis_char2
      @title2_check = @title2_check + COMMA_SYMBOL + IS_VALID_SUBJECT
    end
    if @content_check == CORRECT_SYMBOL && is_valid_parenthesis_char_content
      @content_check = IS_VALID_SUBJECT
    elsif @content_check != CORRECT_SYMBOL && is_valid_parenthesis_char_content
      @content_check = @content_check + COMMA_SYMBOL + IS_VALID_SUBJECT
    end
  end

end