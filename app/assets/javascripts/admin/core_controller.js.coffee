//= require bootstrap
//= require admin/users_controller

root = (exports ? this)

class root.CoreController
  ROUTES:
    'admin/users': UsersController

  constructor: () ->
    $.ajaxSetup beforeSend: (xhr) ->
      xhr.setRequestHeader "X-CSRF-Token", $("meta[name=\"csrf-token\"]").attr("content")

    # Autoload JS functionality based upon the controller (body id)
    controller_slug = $("body").attr("id").split("-")[0]
    if controller_slug of @ROUTES
      try
        new @ROUTES[controller_slug]