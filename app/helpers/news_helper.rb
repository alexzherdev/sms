# coding: utf-8

module NewsHelper
  NEWS_METHOD_FIELDS = [:id, :title, :content]
  NEWS_HELPER_FIELDS = [:truncated]
  NEWS_FIELDS = NEWS_METHOD_FIELDS + NEWS_HELPER_FIELDS
  
  NEWS_TRUNCATED_LENGTH = 500
  NEWS_EXCERPT_RADIUS = 20
  
  def news_collection(news)
    news.collect do |news_item|
      [news_item.id, sanitize(news_item.title), sanitize(news_item.content), sanitize(format_truncated(news_item))]
    end
  end
  
  def format_truncated(news_item)
    trunc = truncate news_item.content, :length => NEWS_TRUNCATED_LENGTH, :omission => "___"
    return trunc if trunc.length == news_item.content.length 
    index = trunc.chars.rindex /[!\.\?]/
    return trunc unless index
    trunc.chars[0..index] + " " + link_to("Читать дальше", news_item_path(news_item))
  end

end
