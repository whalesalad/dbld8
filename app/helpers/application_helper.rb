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

  def facebook_app_id
    DoubleDate::FACEBOOK_APP_ID
  end

  def unread_message_for

  end

  def yesno(b)
    b ? 'Yes' : 'No'
  end

  def badge_for_event(event)
    return 'info' if event.free?
    (event.earns?) ? 'success' : 'important'
  end

  def cluster_host
    require 'socket'
    Socket.gethostname
  end

end
