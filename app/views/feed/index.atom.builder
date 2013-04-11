atom_feed do |feed|
  feed.title("Recent #{@model.model_name.human}")
  feed.updated(@items.first.created_at) if @items.any?

  @items.each do |item|
    feed.entry(item, url: url_for([:admin, item])) do |entry|
      render partial: "#{@slug.singularize}", locals: { entry: entry, item: item }
    end
  end
end