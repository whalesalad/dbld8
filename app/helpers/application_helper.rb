module ApplicationHelper
  def body_class(extra = nil)
    classes = [params[:controller], "#{params[:controller]}-#{params[:action]}"]
    
    unless extra.blank?
      classes.push extra
    end

    classes.join ' '
  end

  def full_title(page_title)
    base_title = 'DoubleDate'
    if page_title.empty?
      base_title
    else
      "#{base_title} &bull; #{page_title}".html_safe
    end
  end

  def admin_title(title)
    base = "DBLD8 Admin"
    title.empty? ? base : "#{base} &mdash; #{title}".html_safe
  end

  def yesno(b)
    x = b ? :yes : :no
    t(x)
  end

  def badge_for_event(event)
    return 'info' if event.free?
    (event.earns?) ? 'success' : 'important'
  end

  def cluster_host
    Rails.configuration.hostname
  end

  def app_invite_url_for_user(user)
    prefix = "#{Rails.configuration.ios_prefix}://"
    if user.present?
      prefix + "invite/#{@user.invite_slug}"
    else
      prefix + "welcome"
    end
  end

  def smart_app_bar_content
    content = [ "app-id=#{Rails.configuration.app_id}" ]
    if @user.present?
      content << "app-argument=#{app_invite_url_for_user(@user)}"
    end
    content.join ", "
  end

end
