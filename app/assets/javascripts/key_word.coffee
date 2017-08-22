# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  checkInput = (mediaValue, inputText)->
    if inputText is ""
      $("#keyword_input").val('')
      return 'キーワードを入力してください'
    else if mediaValue is null
      return '対象媒体を選択してください'
    else
      return ''

  # reuslt data to export CSV file
  $result_data = []

  $('#keyword_check').click ->
    try
      $result_data = []
      mediaValue = $("#media_combobox").val()
      inputText = $("#keyword_input").val().trim()
      resultCheck = checkInput(mediaValue, inputText)
      if resultCheck isnt ""
        bootbox.alert resultCheck
      else
        bootbox.confirm
          message: 'キーワードチェックしますか？'
          buttons:
            confirm:
              label: 'はい'
              className: 'btn-success'
            cancel:
              label: 'いいえ'
              className: 'btn-danger'
          callback: (result) ->
            if result
              $.ajax({
                url: "/keywords/check"
                data:
                  text: inputText, media: mediaValue
                error: (err)->
                  bootbox.alert '<p>An error has occurred</p>' + err
                success: (data) ->
                  result_table = $('#table-result tbody')
                  html_str = ''
                  if data
                    has_err = $.grep data, (v,i) ->
                      return v[1] == 'x'
                    if has_err.length > 0
                      bootbox.alert 'エラーが見つかりました'
                    else
                      bootbox.alert 'エラーはありません'
                    i = 0
                    while i < data.length
                      html_str += '<tr>' + '<td class="col-xs-6">' + data[i][0] + '</td>' + '<td class="col-xs-6">' + data[i][1] + '</td>' + '</tr>'
                      # init csv data
                      csv_record = [
                        data[i][0]
                        data[i][1]
                      ]
                      $result_data.push csv_record
                      i++
                    result_table.html html_str
                  else
                    bootbox.alert 'エラーが見つかりました'
                type: 'POST'
              })
    catch error
      bootbox.alert "Error something!"

  $('#keyword_csv_download').click (e) ->
    try
      mediaValue = $("#media_combobox").val()
      inputText = $("#keyword_input").val()
      resultCheck = checkInput(mediaValue, inputText)
      if resultCheck isnt ""
        bootbox.alert 'チェック結果がありません'
      else
        e.preventDefault()
        $config =
          quotes: false
          quoteChar: '"'
          delimiter: ','
          encoding: 'UTF-8'
          header: true
          newline: '\u000d\n'
        $fields = [
          'キーワード'
          'キーワード'
        ]
        # download file
        csv_data = Papa.unparse({
          fields: $fields
          data: $result_data
        }, $config)
        csv_file = document.createElement('a')
        # Add the element to the DOM
        document.body.appendChild csv_file
        # The '%EF%BB%BF' is BOM ( byte order mark ) add to header of csv file
        csv_file.setAttribute 'href', 'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeURIComponent(csv_data)
        csv_file.setAttribute 'download', 'keywords.csv'
        csv_file.click()
        return
    catch error
      bootbox.alert "エラーが発生しました"

  $('#keyword_clear').click ->
    if $('#table-result tbody').children().length > 0
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
          if result
            mediaValue = $("#media_combobox")
            inputText = $("#keyword_input")
            tableResult = $("#table-result tbody tr")
            inputText.val("")
            mediaValue.val("")
            tableResult.remove()
          return
    else
      bootbox.alert 'チェック結果がありません'