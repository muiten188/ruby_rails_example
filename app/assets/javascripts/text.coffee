# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  isCheckValid = true
  dataCSV = []
  checkInput = (mediaValue, inputText)->
    if mediaValue is "default"
      return '対象媒体を選択してください'
    else if inputText is ""
      return 'テキストを入力してください'
    else
      return ''
  $('#buttonCheck').click ->
    try
      isCheckValid = true
      bootbox.confirm
        message: 'テキストチェックしますか？'
        buttons:
          confirm:
            label: 'はい'
            className: 'btn-success'
          cancel:
            label: 'いいえ'
            className: 'btn-danger'
        callback: (result) ->
          if result
            mediaValue = $("#media_combobox").find(":selected").val()
            inputText = $("#ta-InputText").val()
            resultCheck = checkInput(mediaValue, inputText)
            textObject = {}
            if resultCheck isnt ""
              bootbox.alert resultCheck
            else
              textObject.text = inputText
              textObject.media = mediaValue
              baseUrl = Utility.getBaseUrl()
              $.ajax({
                url: baseUrl + "text/check"
                contentType: "application/json; charset=utf-8",
                data:
                  JSON.stringify(textObject)
                error: (xhr)->
                  bootbox.alert 'エラーが見つかりました'
                success: (data) ->
                  if data? and data.isSuccess is true
                    #clear data csv file
                    dataCSV = []
                    objectResult = JSON.parse(data.value)
                    tableResult = $("#table-result-text tbody tr")
                    tableResult.remove()
                    renderRowTable index, item for index,item of objectResult
                    if isCheckValid is true 
                      bootbox.alert
                        message: 'エラーはありません'
                        backdrop: true
                    else
                      bootbox.alert
                        message: 'エラーが見つかりました'
                        backdrop: true
                    $('#buttonDownloadCsv_Js').show()
                    window.scrollTo(0, 500)
                  else if data? and data.isSuccess is false
                    bootbox.alert data.message
                  else
                    bootbox.alert 'エラーが見つかりました'
                type: 'POST'
              })
          return
#$('#modal-error').modal()
    catch error
      bootbox.alert "Error something!"
  $('#buttonDownloadCsv_Js').click (e)->
    try
      mediaValue = $("#media_combobox").find(":selected").val()
      inputText = $("#ta-InputText").val()
      resultCheck = checkInput(mediaValue, inputText)
      if resultCheck isnt ""
        bootbox.alert resultCheck
      else
        if dataCSV.length == 0
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
          "タイトル１", 
          "タイトル２", 
          "説明文", 
          "タイトル１", 
          "タイトル２", 
          "説明文"
        ]
        # download file
        csv_data = Papa.unparse({
          fields: $fields
          data: dataCSV
        }, $config)
        csv_file = document.createElement('a')
        # Add the element to the DOM
        document.body.appendChild csv_file
        # The '%EF%BB%BF' is BOM ( byte order mark ) add to header of csv file
        csv_file.setAttribute 'href', 'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeURIComponent(csv_data)
        csv_file.setAttribute 'download', 'Text_RegularCheck.csv'
        csv_file.click()
        return 
    catch error
        bootbox.alert "Error something!"
  $('#buttonClear').click ->
    try
      mediaValue = $("#media_combobox").find(":selected").val()
      inputText = $("#ta-InputText").val()
      resultCheck = checkInput(mediaValue, inputText)
      textObject = {}
      if resultCheck isnt ""
        bootbox.alert 
          message:resultCheck
          backdrop: true
        return
      bootbox.confirm
        message: "チェック結果を消去しますか？"
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
            inputText = $("#ta-InputText")
            tableResult = $("#table-result-text tbody tr")
            if inputText.val() is "" and mediaValue.val() is null
              bootbox.alert "チェック結果がありません"
            else
              inputText.val("")
              mediaValue.val("default")
              tableResult.remove()
              dataCSV=[]
    catch error
      bootbox.alert "Error something!"

  renderRowTable = (index, item)->
    tableBody = $("#table-result-text tbody")
    tableBody.append('<tr class="row col-lg-12">
                        <td class="col-xs-2">' + item.title1 + '</td>
                        <td class="col-xs-2">' + item.title2 + '</td>
                        <td class="col-xs-2">' + item.content + '</td>
                        <td class="col-xs-2 text-center">' + item.title1_check + '</td>
                        <td class="col-xs-2 text-center">' + item.title2_check + '</td>
                        <td class="col-xs-2 text-center">' + item.content_check + '</td>
                        </tr>')
    dataCSV.push([item.title1,item.title2,item.content,item.title1_check,item.title2_check,item.content_check])
    if item.title1_check isnt "-" or item.title2_check isnt "-" or item.content_check isnt "-"
      isCheckValid=false
  window.validateForm =validateForm= ()->
    x = document.forms["textform"]["text"].value;
    if x is "" or $("#media_combobox").val() is null
        bootbox.alert("チェック結果がありません");
        return false;