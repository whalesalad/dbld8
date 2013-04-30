atom_feed do |feed|
  feed.title("DoubleDate: Last #{@items.count} #{@model.model_name.human.pluralize}")
  feed.updated(@items.first.created_at) if @items.any?

  @items.each do |item|
    cache item do
      feed.entry(item, url: url_for([:admin, item])) do |entry|
        render partial: "#{@slug.singularize}", locals: { entry: entry, item: item }
      end
    end
  end
end