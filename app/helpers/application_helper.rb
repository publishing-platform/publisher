module ApplicationHelper
  def strip_scheme_from_url(url)
    url.sub(/^https?:\/\//, "")
  end  

  def render_markdown(content)
    raw(Kramdown::Document.new(content).to_html)
  end

  def name_or_fallback(user)
    user&.name || I18n.t("documents.unknown_user")
  end  
end
