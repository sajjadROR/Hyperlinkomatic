$(document).on 'ready page:load', ->

  $(document).on "blur", '.del input', (event) ->
    value = $(this).val();
    input = $(event.target)

    if value == 'del'
      $.ajax
        dataType: 'script'
        type: 'DELETE'
        data: {delete: value}
        url: input.attr("data-load-event-url")

    if value == 'edt'
      edi_url = input.attr("data-load-event-url") + "/edit"
      $.ajax
        dataType: 'script'
        type: 'GET'
        data: {delete: value}
        url: edi_url