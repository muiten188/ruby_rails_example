###*
# Created by TheSun on 07/12/2017.
###

# /Panel toolbox

changePos = (currPos, expectedPos) ->
  `var diff`
  `var sign`
  if currPos > expectedPos
    diff = currPos - expectedPos
    sign = '-='
  else
    diff = expectedPos - currPos
    sign = '+='
  finalPos = sign + diff
  finalPos

$(document).ready ->
  $('.navigation').mouseleave ->
#returnToActive();
    $('.sliding-line').hide()
    return
  $('.navigation li').mouseenter(->
    slidingArrow = $('.sliding-line')
    if slidingArrow.css('display') == 'none'
      slidingArrow.show()
    leftPadding = $(this).css('padding-left').replace('px', '')
    newPadding = parseFloat(leftPadding)
    #if (!($(this).hasClass('active'))) {
    #var slidingArrow = $('.sliding-line');
    currPos = slidingArrow.offset().left
    currWidth = $(this).css('width').replace('px', '')
    currWidth = parseInt(currWidth) - 40
    expectedPos = $(this).offset().left + newPadding
    #(currWidth);// + parseFloat(40);
    #slidingArrow.css({width: currWidth}, 600, 'swing', function(){});
    slidingArrow.stop().animate {
      width: currWidth + 'px'
      left: changePos(currPos, expectedPos)
    }, 400, 'easeOutQuint', ->
#var expectedPos = $(this).offset().left + 25; //(currWidth);// + parseFloat(40);
#slidingArrow.stop().animate({left: changePos(currPos,expectedPos)}, 400, 'swing', function(){});
#}
    return
  ).mouseleave ->
#returnToActive();
#slidingArrow.show();
    return
  $('.navigation li').on 'click', ->
    link = $(this).attr('href')
    window.location = link
    return
  menu_height = $('.menu.fixed').css('height')
  $('.content').css 'margin-top', menu_height
  return
# Panel toolbox
$(document).ready ->
  $('.collapse-link').on 'click', ->
    $BOX_PANEL = $(this).closest('.x_panel')
    $ICON = $(this).find('i')
    $BOX_CONTENT = $BOX_PANEL.find('.x_content')
    # fix for some div with hardcoded fix class
    if $BOX_PANEL.attr('style')
      $BOX_CONTENT.slideToggle 200, ->
        $BOX_PANEL.removeAttr 'style'
        return
    else
      $BOX_CONTENT.slideToggle 200
      $BOX_PANEL.css 'height', 'auto'
    $ICON.toggleClass 'fa-chevron-up fa-chevron-down'
    return
  $('.close-link').click ->
    $BOX_PANEL = $(this).closest('.x_panel')
    $BOX_PANEL.remove()
    return
  return
# handle tab in text area
$(document).delegate '.text-area-custom', 'keydown', (e) ->
  keyCode = e.keyCode or e.which
  if keyCode == 9
    e.preventDefault()
    start = $(this).get(0).selectionStart
    end = $(this).get(0).selectionEnd
    # set textarea value to: text before caret + tab + text after caret
    $(this).val $(this).val().substring(0, start) + '\u0009' + $(this).val().substring(end)
    # put caret at right position again
    $(this).get(0).selectionStart = $(this).get(0).selectionEnd = start + 1
  return
$(document).ready ->
  $('.loader').hide()
  #initially hide the loading icon
  $(document).ajaxStart ->
    $('.loader').show()
    console.log 'shown loader icon when start call ajax'
    return
  $(document).ajaxStop ->
    $('.loader').hide()
    console.log 'hidden loader icon when finish call ajax'
    return
  return