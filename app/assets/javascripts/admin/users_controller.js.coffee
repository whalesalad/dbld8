root = (exports ? this)

class root.UsersController
  constructor: () ->
    $('ul.user-tabs a:first').tab 'show'