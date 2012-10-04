class Admin::FriendshipsController < AdminController
  before_filter :get_friendship, :only => [:show, :edit, :update, :destroy]

  def index
    @friendships = Friendship.order('created_at DESC')
  end

  def show
    # respond_with
  end

  def new
    @friendship = Friendship.new
  end

  def create
    @friendship = Friendship.new(params[:friendship])
    
    if @friendship.save
      redirect_to admin_friendships_path, success: 'The friendship has been created successfully.'
    else
      render action: "new"
    end
  end

  def destroy
    @friendship.destroy
    redirect_to admin_friendships_path, :flash => { :success => "Successfully deleted friendship #{@friendship.to_s}." }
  end

  protected

  def get_friendship
    @friendship = Friendship.find_by_id(params[:id])
  end
end
