###*
# Created by TheSun on 07/18/2017.
###

$(document).on 'ready', ->
# init forData which contain "files" to upload
  formData = new FormData
  # download csv result file
  $data = []
  # handle data response from server when upload successful
  fileBatchUpLoadSuccess = (response) ->
    console.log 'File batch upload success'
    # show dialog when there is error or not
    if response.is_has_error
      bootbox.alert
        message: 'エラーが見つかりました'
        backdrop: true
    else
      bootbox.alert
        message: 'エラーはありません'
        backdrop: true
    # get data responsive to handle
    results = response.data
    body = $('#resultTable').find('tbody')
    # loop to get info of each file after check
    i = 0
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
        fileSizeCheck = 'x'
      fileTypeCheck = ''
      if result.file_type_check
        fileTypeCheck = '-'
      else
        fileTypeCheck = 'x'
      bannerSizeCheck = ''
      if result.file_type_check
        if result.dimensions_check
          bannerSizeCheck = '-'
        else
          bannerSizeCheck = 'x'
      # create row data
      tr = '<tr>' + '<td class=\'col-md-2 text-left\'>' + result.file_name + '</td>' + '<td class=\'col-md-1 text-center\'>' + result.file_type + '</td>' + '<td class=\'col-md-2 text-center\'>' + bannerSize + '</td>' + '<td class=\'col-md-2 text-center\'>' + (result.file_size / 1024).toFixed(2) + ' KB' + '</td>' + '<td class=\'col-md-1 text-center\'>' + fileTypeCheck + '</td>' + '<td class=\'col-md-2 text-center\'>' + bannerSizeCheck + '</td>' + '<td class=\'col-md-2 text-center\'>' + fileSizeCheck + '</td>' + '</tr>'
      # init csv data
      csv_record = [
        result.file_name
        result.file_type
        bannerSize
        (result.file_size / 1024).toFixed(2) + ' KB'
        fileSizeCheck
        bannerSizeCheck
        fileTypeCheck
      ]
      $data.push csv_record
      # if file type is "zip" file and media"_type is "GDN" then
      # get all child files info in "zip" file
      if result.media_type == 'GDN' and result.file_type == 'zip'
        console.log 'Loop in zip file' + result.file_name
        j = 0
        while j < result.file_children.length
          child = result.file_children[j]
          bannerSizeChild = ''
          if child.dimensions[0] != undefined
            bannerSizeChild = child.dimensions[0] + 'x' + child.dimensions[1]
          fileSizeChildCheck = ''
          if child.file_size_check
            fileSizeChildCheck = '-'
          else
            fileSizeChildCheck = 'x'
          fileTypeChildCheck = ''
          if child.file_type_check
            fileTypeChildCheck = '-'
          else
            fileTypeChildCheck = 'x'
          bannerSizeChildCheck = ''
          if child.file_type_check
            if child.dimensions_check
              bannerSizeChildCheck = '-'
            else
              bannerSizeChildCheck = 'x'
          tr += '<tr>' + '<td class=\'col-md-2 text-center\'>' + child.file_name + '</td>' + '<td class=\'col-md-1 text-center\'>' + child.file_type + '</td>' + '<td class=\'col-md-2 text-center\'>' + bannerSizeChild + '</td>' + '<td class=\'col-md-2 text-center\'>' + (child.file_size / 1024).toFixed(2) + ' KB' + '</td>' + '<td class=\'col-md-1 text-center\'>' + fileTypeChildCheck + '</td>' + '<td class=\'col-md-2 text-center\'>' + bannerSizeChildCheck + '</td>' + '<td class=\'col-md-2 text-center\'>' + fileSizeChildCheck + '</td>' + '</tr>'
          #  init child csv record
          child_csv_record = [
            child.file_name
            child.file_type
            bannerSizeChild
            (child.file_size / 1024).toFixed(2) + ' KB'
            fileTypeChildCheck
            bannerSizeChildCheck
            fileSizeChildCheck
          ]
          $data.push child_csv_record
          j++
      # add row to body of table
      body.append tr
      # show button down load
      $('#downloadCsv').show()
      i++
    $('#resultTable').show()
    return

  # handle upload action
  upload = ->
# clear old result in table
    clear_file_result()
    # add extra data "media_type" to form data to upload
    formData.append 'media_type', $media_type
    $.ajax
      url: '/banner/upload'
      type: 'POST'
      datatype: 'json'
      data: formData
      cache: false
      processData: false
      contentType: false
      success: (result) ->
        fileBatchUpLoadSuccess result
        return
      error: (xhr) ->
        alert 'Error: ' + xhr.statusText
        return
    return

  clear_file_result = ->
# clear old result in table
    $('#resultTable').find('tbody tr').remove()
    # hidden "down load csv"
    $data = []
    return

  # handle file download csv check result
  $('#downloadCsv').on 'click', (e) ->
# check if there is no data then show alert to user
    if $data.length == 0
      bootbox.alert
        message: 'チェック結果がありません'
        backdrop: true
      return
    e.preventDefault()
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
      'バナーサイズ'
      'ファイルサイズ'
      '拡張子'
      'バナーサイズ'
      'ファイルサイズ'
    ]
    # download file
    csv_data = Papa.unparse({
      fields: $fields
      data: $data
    }, $config)
    csv_file = document.createElement('a')
    # Add the element to the DOM
    document.body.appendChild csv_file
    # The '%EF%BB%BF' is BOM ( byte order mark ) add to header of csv file
    csv_file.setAttribute 'href', 'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeURIComponent(csv_data)
    csv_file.setAttribute 'download', 'banner_image.csv'
    csv_file.click()
    return

  # init file input plugin
  $media_type = ''
  $fileInput = $('#input-folder')

  initPlugin = ->
    $fileInput.fileinput
      browseLabel: '参照...'
      allowedPreviewTypes: false
      showPreview: false
      uploadClass: 'hidden'
    return

  initPlugin()
  # clear text result check
  $('#file-clear').on 'click', (e) ->
    if $data.length == 0
      bootbox.alert
        message: 'チェック結果がありません'
        backdrop: true
      return false
    bootbox.confirm
      message: 'チェック結果を消去しますか？'
      buttons:
        confirm:
          label: 'はい'
          className: 'btn-success'
        cancel:
          label: 'いいえ'
          className: 'btn-danger'
      callback: (result) ->
# if user choose "yes" then clear all old text result check
        console.log 'This was logged in the callback: ' + result
        if result
          clear_file_result()
        return
    return
  # change value of "media_type" when user change select box
  $('#media_type').on 'change', ->
    $media_type = $('#media_type').val()
    console.log $media_type
    return
  # handle upload files when button clicked
  $('.upload').on 'click', ->
# check if there is no folder choose then show alert
    if !$('#chooseFolder').val()
      bootbox.alert
        message: 'フォルダを選択してください'
        backdrop: true
      return false
    # check if there is no media_type("GDN","YDN") choose then show alert
    if $media_type
# if folder and media_type choose then show confirm dialog,
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
# if user choose "yes" then call "upload" function to upload files
          console.log 'This was logged in the callback: ' + result
          if result
            upload()
          return
    else
# there is no media_type("GDN","YDN") choose then show alert
      bootbox.alert
        message: '対象媒体を選択してください'
        backdrop: true
      return false
    return
  # change val of "chooseFolder" when pressed "select folder" button
  $('#input-folder').on 'change', (event) ->
    console.log 'change'
    $('#chooseFolder').val 'true'
    # show "loader" icon when start load files into "formData" with "num of files > 0"
    if event.originalEvent.currentTarget.files && event.originalEvent.currentTarget.files.length > 0
      $('.loader').show()
    return
  # clear val of "chooseFolder"  when pressed delete
  $('#input-folder').on 'fileclear', ->
    console.log 'fileclear'
    $('#chooseFolder').val ''
    #    reset "formData"
    formData = new FormData
    return
  # get all files in folder selected and append them to "formData"
  $('#input-folder').on 'filebatchselected', (event, files) ->
# Load all files in the folder into "formData" to upload
    if files and files.length
# reset formData
      formData = new FormData
      $.each files, (key, data) ->
        if files[key]
          formData.append 'input-folder[]', data, data.name
        return
    else
# delete "media_type" property
      formData.delete 'media_type'
    # end load files then hidden "loader" icon
    $('.loader').hide()
    console.log 'File batch selected triggered'
    return
  return