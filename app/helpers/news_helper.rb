# encoding: UTF-8
module NewsHelper

  # Build at least 6 links for a news
  # and always add a blank new link,
  # so people without js can add as many links as they want
  # (one new per preview).
  def setup_news(news)
    (news.links.size ... 5).each { news.links.build }
    news.links.build
    news
  end

  def news_posted_by(news)
    (posted_by(news, news.user ? nil : news.author_name) + moderated_by(news)).html_safe
  end

  def moderated_by(news)
    news.moderator ? " Modéré par #{link_to news.moderator.name, news.moderator}.".html_safe : ""
  end

end
