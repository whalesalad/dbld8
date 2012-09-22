module AdminHelper
  def current_section?(options)
    unless request
      raise "You cannot use helpers that need to determine the current " \
            "page unless your view context provides a Request object " \
            "in a #request method"
    end

    return false unless request.get?

    url_string = url_for(options)

    if url_string.index("?")
      request_uri = request.fullpath
    else
      request_uri = request.path
    end

    if url_string =~ /^\w+:\/\//
      url_string == "#{request.protocol}#{request.host_with_port}#{request_uri}"
    else
      request_uri.starts_with?(url_string)
    end
  end

end