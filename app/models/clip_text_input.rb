# This class is referred by "YDN動画広告" screen
class ClipTextInput < BaseTextInput
  attr_accessor :resultTitle1, :resultContent
  TITLE_SIZE = 20
  CONTENT_SIZE = 90
  ACCEPTED_CHARS = /^[a-zA-Z0-9Ａ-ｚ０-９ぁ-んァ-ン一-龯ー（）［］「」『』｛｝＜＞≪≫()‘’｀´“”。、・，,．.＿～％＆：；:;
                    …‐＋－±×÷=∞\-―+／＼？！?!⇒⇔→←↑↓￥＄＊＃♪＠〃〆※〒 ]+$/

  def initialize(attributes = {})
    super
    @title1 ||= 'wrong'
    @content ||= 'wrong'
    @resultTitle1 ||= 'x'
    @resultContent ||= 'x'
  end

  # check max length of string
  # if true, return true
  # if wrong, return number over character
  def count_char(text, valid_length)
    if text.length <= valid_length
      return true
    else
      return (text.length - valid_length)
    end
  end
end