class Admin::UsersController < AdminController
  before_filter :fetch_user, :only => [:show, :edit, :update, :destroy]
  # cache_sweeper :post_sweeper, only: [:create, :update, :destroy]

  def index
    @posts = User.order('created_at DESC')
  end

  def new
    @post = User.new
  end

  def edit

  end

  def create
    @post = Post.new(params[:post])
    
    if @post.save
      redirect_to admin_posts_path, notice: 'BOOM look at you blogging like a boss.'
    else
      render action: "new"
    end
  end

  def update
    if @post.update_attributes(params[:post])
      flash[:notice] = 'Successfully updated post.'
      redirect_to admin_posts_path
    else
      render 'edit'
    end
  end

  def destroy
    @post.destroy
    flash[:notice] = 'Successfully destroyed post.'
    redirect_to admin_posts_url
  end

  protected

  def fetch_user
    @user = Post.find_by_id(params[:id])
  end
end
