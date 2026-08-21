module ApplicationHelper
  def markdown(text)
  renderer = Redcarpet::Render::HTML.new(
    filter_html: true,
    hard_wrap: true
  )

  markdown = Redcarpet::Markdown.new(renderer)

  sanitize(
    markdown.render(text),
    tags: %w[h1 h2 h3 p strong em ul ol li br]
  )
end
end
