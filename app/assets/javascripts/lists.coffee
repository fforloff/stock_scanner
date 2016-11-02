# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $('#companies-ajax').select2
    width: '300px'
    tags: [ '' ]
    minimumInputLength: 2
    tokenizer: (input, selection, callback) ->
      if input.indexOf(',') < 0 and input.indexOf(' ') < 0
        return
      parts = input.split(/,| /)
      i = 0
      while i < parts.length
        part = parts[i]
        part = part.trim()
        callback
          id: part
          text: part
        i++
      return
    placeholder: "Select..."
    ajax:
      url: '/companies/autocomplete.json'
      dataType: 'json'
      delay: 250
      data: (params) ->
        {
          q: params.term
          page: params.page
        }
      processResults: (data, page) ->
        { results: $.map(data, (company, i) ->
          {
            id: company._id
            text: company.ticker
          }
        ) }
  $("#companies-ajax").select2 "data", gon.list_companies
