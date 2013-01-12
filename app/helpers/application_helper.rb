module ApplicationHelper
  def body_class(extra = nil)
    classes = [params[:controller], "#{params[:controller]}-#{params[:action]}"]
    
    unless extra.blank?
      classes.push extra
    end

    classes.join ' '
  end

  def full_title(page_title)
    base_title = 'DBLD8'
    if page_title.empty?
      base_title
    else
      "#{base_title} &bull; #{page_title}".html_safe
    end
  end

  def facebook_app_id
    DoubleDate::FACEBOOK_APP_ID
  end

  def gender_posessive(gender)
    (gender == "male") ? "his" : "her"
  end

  def true_false(s)
    (s == 't') ? true : false
  end
end
