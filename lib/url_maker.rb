module UrlMaker
  def self.embed_show_product_url(guid, pid, currency, locale)
    "/embed/show?toguid=#{guid}&pid=#{pid}&currency=#{currency}&locale=#{locale}"
  end
end