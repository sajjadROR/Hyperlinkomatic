$(document).on 'ready page:load', ->

  $(document).on "blur", '.del input', (event) ->
    $(this).css 'background-color', 'yellow'
    value = $(this).val();
    input = $(event.target)
    $.ajax
      dataType: 'script'
      type: 'DELETE'
      data: {delete: value}
      url: input.attr("data-load-event-url")