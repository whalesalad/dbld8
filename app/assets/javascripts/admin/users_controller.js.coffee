root = (exports ? this)

class root.UsersController
  constructor: () ->
    $('a.send-push').bind 'click', ->
      url = $(this).attr('href')
      button = $(this)

      push = $.get(url, ->
        button.text('Sending...').addClass('disabled')
      )

      push.always = ->
        setTimeout (->
          button.removeClass("disabled").text "Send Push Notification"
        ), 1000

      false