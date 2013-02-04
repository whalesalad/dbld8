root = (exports ? this)

class root.EngagementsController
  constructor: () ->
    # unlock_modal = 

    $('a.unlock-engagement').bind 'click', ->
      engagement_id = $(this).data 'engagement'
      user_id = $(this).data 'user'
      
      $.post "/admin/engagements/#{engagement_id}/unlock", 
        user_id: user_id
      , (data) ->
        console.log data

      # console.log engagement_id, user_id

      return false