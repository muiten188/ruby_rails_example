# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'ready', ->

# check MOVIES
  $clips_data = []
  # download CSV file
  $('#clip_csv_download').on 'click', (e) ->
    e.preventDefault()
    if $clips_data.length == 0
      bootbox.alert 'チェック結果がありません'
      return
    $config =
      quotes: false
      quoteChar: '"'
      delimiter: ','
      encoding: 'UTF-8'
      header: true
      newline: '\u000d\n'
    $fields = [
      '動画ファイル'
      '音声コーデック'
      '動画コーデック'
      'アスペクト比'
      '最小映像ビットレート'
      '最小音声ビットレート'
      'その他'
    ]
    # download file
    csv_data = Papa.unparse({
      fields: $fields
      data: $clips_data
    }, $config)
    csv_file = document.createElement('a')
    # Add the element to the DOM
    document.body.appendChild csv_file
    # The '%EF%BB%BF' is BOM ( byte order mark ) add to header of csv file
    csv_file.setAttribute 'href', 'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeURIComponent(csv_data)
    csv_file.setAttribute 'download', 'clip_movie.csv'
    csv_file.click()
    return

  # init file input plugin
  $('#clip_input-folder').fileinput
    browseLabel: '参照...'
    allowedPreviewTypes: false
    showPreview: false
    uploadUrl: '/clip/upload_clip'
    uploadAsync: false
    uploadClass: "hidden"
    layoutTemplates: {progress: ''}

  # validate upload data
  $('.clip_upload').on 'click', ->
    if !$('#chooseFolder1').val()
      bootbox.alert 'フォルダを選択してください'
      return false

    bootbox.confirm
      message: 'チェックしますか？'
      buttons:
        confirm:
          label: 'はい'
          className: 'btn-success'
        cancel:
          label: 'いいえ'
          className: 'btn-danger'
      callback: (result) ->
        console.log 'This was logged in the callback: ' + result
        if result
          $('.clip_chooser .fileinput-upload').click()
        return
    return
  # change val of "chooseFolder" when pressed "select folder" button
  $('#clip_input-folder').on 'change', ->
    console.log 'change'
    $('#chooseFolder1').val 'true'
    return
  # clear val of "chooseFolder"  when pressed delete
  $('#clip_input-folder').on 'fileclear', (event) ->
    console.log 'fileclear'
    $('#chooseFolder1').val ''
    return

  # fill result check into table
  $('#clip_input-folder').on 'filebatchuploadsuccess', (event, data, previewId, index) ->
    console.log 'File batch upload success'
    # clear old result
    $('#clip-result').find('tbody tr').remove()
    $clips_data = []
    results = data.response
    if results.has_err
      bootbox.alert results.message
      return

    body = $('#clip-result').find('tbody')
    i = 0

    # get result message
    msg_flag = true

    while i < results.length
# init table body
      result = results[i]
      if result.has_sound == false
        result.audio_bit_rate_check = 'x'
        result.audio_codec_check = 'x'
      else
        if result.audio_bit_rate_check
          result.audio_bit_rate_check = '-'
        else
          msg_flag = false
          result.audio_bit_rate_check = 'x'

        if result.audio_codec_check
          result.audio_codec_check = '-'
        else
          msg_flag = false
          result.audio_codec_check = 'x'

      if result.video_codec_check
        result.video_codec_check = '-'
      else
        msg_flag = false
        result.video_codec_check = 'x'

      if result.bit_rate_check
        result.bit_rate_check = '-'
      else
        msg_flag = false
        result.bit_rate_check = 'x'

      if result.aspect_ratio_check
        result.aspect_ratio_check = '-'
      else
        msg_flag = false
        result.aspect_ratio_check = 'x'

      other = ''
      if result.has_sound
        other += '音声有'
      else
        other += '音声無し'

      other += '、moov_atom: ' + result.moov_atom
      if result.has_sound
        other += '、最大ボリューム: ' + result.sound_volume + 'dB'
      other += '、フレームレート: ' + Math.round(result.frame.split('/')[0] / result.frame.split('/')[1],)
      other += '、再生時間: ' + Math.round(result.duration) + 's'
      other += '、メージャーブランド: ' + result.major_brand


      tr = '<tr>' + '<td class=\'text-left\' style="width: 20%">' + result.file_name + '</td>' +
        '<td class=\'text-center\' style="width: 15%">' + result.audio_codec_check + '</td>' +
        '<td class=\'text-center\' style="width: 15%">' + result.video_codec_check + '</td>' +
        '<td class=\'text-center\' style="width: 10%">' + result.aspect_ratio_check + '</td>' +
        '<td class=\'text-center\' style="width: 15%">' + result.bit_rate_check + '</td>' +
        '<td class=\'text-center\' style="width: 15%">' + result.audio_bit_rate_check + '</td>' +
        '<td class=\'text-center\' style="width: 10%">' + other + '</td>' +
        '</tr>'
      body.append tr
      # init csv data
      csv_record = [
        result.file_name
        result.audio_codec_check
        result.video_codec_check
        result.aspect_ratio_check
        result.bit_rate_check
        result.audio_bit_rate_check
        other
      ]
      $clips_data.push csv_record
      i++
    if msg_flag
      bootbox.alert 'エラーはありません'
    else
      bootbox.alert 'エラーが見つかりました'
    return

  # clear result table
  $('#clip_clear').click ->
    bootbox.confirm({
      message: "チェック結果を消去しますか？"
      buttons: {
        confirm: {
          label: 'はい',
          className: 'btn-success'
        },
        cancel: {
          label: 'いいえ',
          className: 'btn-danger'
        }
      },
      callback: (result) ->
        if result
          if $clips_data.length == 0
            bootbox.alert 'チェック結果がありません'
            return
          else
            body = $('#clip-result').find('tbody')
            body.html('')
            $clips_data = []
            $('.clip_chooser .fileinput-remove').click()
            $('#chooseFolder1').val ''
    })

# check IMAGES
  $images_data = []
  # download CSV file
  $('#image_csv_download').on 'click', (e) ->
    e.preventDefault()
    if $images_data.length == 0
      bootbox.alert 'チェック結果がありません'
      return
    $config =
      quotes: false
      quoteChar: '"'
      delimiter: ','
      encoding: 'UTF-8'
      header: true
      newline: '\u000d\n'
    $fields = [
      'ファイル名'
      '拡張子'
      'ピクセルサイズ'
      'ファイルサイズ'
      '拡張子'
      'ピクセルサイズ'
      'ファイルサイズ'
    ]
    # download file
    csv_data = Papa.unparse({
      fields: $fields
      data: $images_data
    }, $config)
    csv_file = document.createElement('a')
    # Add the element to the DOM
    document.body.appendChild csv_file
    # The '%EF%BB%BF' is BOM ( byte order mark ) add to header of csv file
    csv_file.setAttribute 'href', 'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeURIComponent(csv_data)
    csv_file.setAttribute 'download', 'clip_image.csv'
    csv_file.click()
    return

  # init plug-in browse file input
  $('#image_input-folder').fileinput
    browseLabel: '参 照'
    allowedPreviewTypes: false
    showPreview: false
    uploadUrl: '/clip/upload_image'
    uploadAsync: false
    uploadClass: "hidden"
    layoutTemplates: {progress: ''}

  # Validate data upload
  $('.image_upload').on 'click', ->
    if !$('#chooseFolder2').val()
      bootbox.alert 'フォルダを選択してください'
      return false

    bootbox.confirm
      message: 'チェックしますか？'
      buttons:
        confirm:
          label: 'はい'
          className: 'btn-success'
        cancel:
          label: 'いいえ'
          className: 'btn-danger'
      callback: (result) ->
        console.log 'This was logged in the callback: ' + result
        if result
          $('.image_chooser .fileinput-upload').click()
        return
    return

  # change val of "chooseFolder" when pressed "select folder" button
  $('#image_input-folder').on 'change', ->
    console.log 'change'
    $('#chooseFolder2').val 'true'
    return

  $('#image_input-folder').on 'filebatchuploadsuccess', (event, data, previewId, index) ->
    console.log 'File batch upload success'
    # clear old result
    $('#image-result').find('tbody tr').remove()
    $images_data = []
    results = data.response
    body = $('#image-result').find('tbody')
    i = 0

    # get result message
    msg_flag = true
    while i < results.length
      # init table body
      result = results[i]
      bannerSize = ''
      if result.dimensions[0] != undefined
        bannerSize = result.dimensions[0] + 'x' + result.dimensions[1]
      fileSizeCheck = ''
      if result.file_size_check
        fileSizeCheck = '-'
      else
        msg_flag = false
        fileSizeCheck = 'x'
      fileTypeCheck = ''
      if result.file_type_check
        fileTypeCheck = '-'
      else
        msg_flag = false
        fileTypeCheck = 'x'
      dimensionsCheck = ''
      if result.file_type_check
        if result.dimensions_check
          dimensionsCheck = '-'
        else
          msg_flag = false
          dimensionsCheck = 'x'
      fileSize = Math.round(result.file_size / 1024) + 'KB'
      tr = '<tr>' + '<td class=\'col-md-2 text-left\'>' + result.file_name + '</td>' +
            '<td class=\'col-md-1 text-center\'>' + result.file_type + '</td>' +
            '<td class=\'col-md-2 text-center\'>' + bannerSize + '</td>' +
            '<td class=\'col-md-2 text-center\'>' + fileSize + '</td>' +
            '<td class=\'col-md-1 text-center\'>' + fileTypeCheck + '</td>' +
            '<td class=\'col-md-2 text-center\'>' + dimensionsCheck + '</td>' +
            '<td class=\'col-md-2 text-center\'>' + fileSizeCheck + '</td>' +
          '</tr>'
      body.append tr
      # init csv data
      csv_record = [
        result.file_name
        result.file_type
        bannerSize
        result.file_size
        fileSizeCheck
        dimensionsCheck
        fileTypeCheck
      ]
      $images_data.push csv_record
      i++
    if msg_flag
      bootbox.alert 'エラーはありません'
    else
      bootbox.alert 'エラーが見つかりました'
    return

  # clear result table
  $('#image_clear').click ->
    bootbox.confirm({
        message: "チェック結果を消去しますか？"
        buttons: {
          confirm: {
            label: 'はい',
            className: 'btn-success'
          },
          cancel: {
            label: 'いいえ',
            className: 'btn-danger'
          }
        },
        callback: (result) ->
          if result
            if $images_data.length == 0
              bootbox.alert 'チェック結果がありません'
              return
            else
              body = $('#image-result').find('tbody')
              body.html('')
              $images_data = []
              $('.image_chooser .fileinput-remove').click()
              $('#chooseFolder2').val ''
    })

# check TEXT
  $text_data = []
  # download CSV file
  $('#keyword_csv_download').on 'click', (e) ->
    e.preventDefault()
    if $text_data.length == 0
      bootbox.alert 'チェック結果がありません'
      return
    $config =
      quotes: false
      quoteChar: '"'
      delimiter: ','
      encoding: 'UTF-8'
      header: true
      newline: '\u000d\n'
    $fields = [
      'タイトル'
      '説明文'
      'タイトル'
      '説明文'
    ]
    # download file
    csv_data = Papa.unparse({
      fields: $fields
      data: $text_data
    }, $config)
    csv_file = document.createElement('a')
    # Add the element to the DOM
    document.body.appendChild csv_file
    # The '%EF%BB%BF' is BOM ( byte order mark ) add to header of csv file
    csv_file.setAttribute 'href', 'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeURIComponent(csv_data)
    csv_file.setAttribute 'download', 'clip_text.csv'
    csv_file.click()
    return
  $('#keyword_check').click ->
    if $('#keyword_input').val().trim() == ''
      bootbox.alert 'テキストを入力してください'
      $('#keyword_input').val('')
      return
    try
      bootbox.confirm({
        message: "チェックしますか？"
        buttons: {
          confirm: {
            label: 'はい',
            className: 'btn-success'
          },
          cancel: {
            label: 'いいえ',
            className: 'btn-danger'
          }
        },
        callback: (result) ->
          # if user choose "yes" then call "upload" function to upload files
          console.log 'This was logged in the callback: ' + result
          if result
            inputText = $("#keyword_input").val()
            $.ajax({
              url: "/clip/upload_text"
              data:
                text: inputText
              error: (err)->
                bootbox.alert 'エラーが発生しました' + err
              success: (data) ->
                body = $('#text-result').find('tbody')
                body.html('')
                $text_data = []
                if data.has_err
                  bootbox.alert data.message
                  return
                # get result message
                msg_flag = true
                data.forEach (text) ->
                  if text.resultTitle1 != '-' || text.resultContent != '-'
                    msg_flag = false
                  tr = '<tr>' + '<td class=\'text-left col-xs-2\'>' + text.title1 + '</td>' +
                      '<td class=\'text-left col-xs-8\'>' + text.content + '</td>' +
                      '<td class=\'text-center col-xs-1\'>' + text.resultTitle1 + '</td>' +
                      '<td class=\'text-center col-xs-1\'>' + text.resultContent + '</td>' +
                    '</tr>'
                  body.append tr

                  # init csv data
                  csv_record = [
                    text.title1
                    text.content
                    text.resultTitle1
                    text.resultContent
                  ]
                  $text_data.push csv_record
                if msg_flag
                  bootbox.alert 'エラーはありません'
                else
                  bootbox.alert 'エラーが見つかりました'
              type: 'POST'
            })
      })
    catch error
      bootbox.alert "エラーが発生しました"

  # clear result table
  $('#keyword_clear').click ->
    bootbox.confirm({
      message: "チェック結果を消去しますか？"
      buttons: {
        confirm: {
          label: 'はい',
          className: 'btn-success'
        },
        cancel: {
          label: 'いいえ',
          className: 'btn-danger'
        }
      },
      callback: (result) ->
        if result
          if $images_data.length == 0
            bootbox.alert 'チェック結果がありません'
            return
          else
            body = $('#text-result').find('tbody')
            body.html('')
            $text_data = []
    })