class Admin::FacebookInvitesController < AdminController
  def index
    @invites = FacebookInvite.order('created_at DESC')
  end

  def destroy_multiple
    to_delete = params[:invites_to_delete]

    FacebookInvite.delete(to_delete)

    redirect_to admin_facebook_invites_path, :flash => { :success => "Successfully deleted #{to_delete.count} invite(s)." }
  end
end
