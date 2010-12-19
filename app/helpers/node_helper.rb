# encoding: UTF-8
module NodeHelper

  ContentPresenter = Struct.new(:record, :title, :meta, :image, :body, :actions, :css_class) do
    def to_hash
      attrs = members.map(&:to_sym)
      Hash[*attrs.zip(values).flatten(1)]
    end

    def self.collection?
      !!@collection
    end

    def self.collection(&blk)
      @collection = true
      yield
    ensure
      @collection = false
    end
  end

  def article_for(record)
    cp = ContentPresenter.new
    cp.record = record
    cp.css_class = %w(node)
    score = [ [record.node.score / 5, -10].max, 10].min
    cp.css_class << "score#{score}"
    cp.css_class << record.class.name.downcase
    cp.css_class << 'new-node' if current_account && record.node.read_status(current_account) == :not_read
    yield cp
    cp.meta ||= posted_by(record)
    cp.body ||= sanitize(ContentPresenter.collection? ?
                         record.truncated_body.sub("[...](suite)", " " + link_to("(...)", url_for_content(record))) :
                         record.body)
    render 'nodes/content', cp.to_hash
  end

  def editable_field(record, field)
    value = record.send(field)
    obj = ActionController::RecordIdentifier.singular_class_name(record)
    content_tag(:span, value, :class => 'rest_in_place', :"data-attribute" => field, :"data-object" => obj)
  end

  def link_to_content(content)
    link_to content.title, url_for_content(content)
  end

  def paginated_nodes(nodes, link=nil)
    paginated_section(nodes, link) do
      content_tag(:div, render(nodes.map &:content), :id => 'contents')
    end
  end

  def paginated_contents(contents, link=nil)
    paginated_section(contents, link) do
      content_tag(:div, render(contents), :id => 'contents')
    end
  end

  def paginated_section(args, link=nil, &block)
    toolbox    = link ? content_tag(:div, link, :class => 'new_content') : ''.html_safe
    order_bar  = render 'shared/order_navbar'
    pagination = will_paginate(args).to_s
    before = content_tag(:nav, toolbox + order_bar + pagination, :class => "toolbox")
    after  = content_tag(:nav, pagination, :class => "toolbox")
    ContentPresenter.collection do
      before + capture(&block) + after
    end
  end

  def pubdate_for(content)
    (content.created_at || Time.now).iso8601
  end

  def posted_by(content, user_link=nil)
    user   = content.user
    user ||= current_user if content.new_record?
    user_link = 'Anonyme'
    if user
      user_link  = link_to(user.name, user, :rel => 'author')
      user_infos = []
      user_infos << link_to("page perso", user.homesite)             if user.homesite.present?
      user_infos << link_to("jabber id", "xmpp://" + user.jabber_id) if user.jabber_id.present?
      user_link += (" (" + user_infos.join(', ') + ")").html_safe    if user_infos.any?
    end
    date_time    = content.is_a?(Comment) ? content.created_at : content.node.try(:created_at)
    date_time  ||= Time.now
    date         = content_tag(:span, "le #{date_time.to_s(:date)}", :class => "date")
    time         = content_tag(:span,  "à #{date_time.to_s(:time)}", :class => "time")
    published_at = content_tag(:time, date + " " + time, :datetime => pubdate_for(content), :pubdate => "pubdate")
    "Posté par #{user_link} #{published_at}.".html_safe
  end

  def read_it(content)
    link = link_to_unless_current("Lire la suite", url_for_content(content)) { "" }
    nb_comments = pluralize(content.node.try(:comments_count), "commentaire")
    if current_account
      visit = case content.node.read_status(current_account)
              when :not_read     then ", non visité"
              when :new_comments then ", Nouveaux !"
              else                    ", déjà visité"
              end
    end
    "#{link} (#{nb_comments}#{visit}).".html_safe
  end

  def translate_content_type(content_type)
    t "activerecord.models.#{content_type.downcase}"
  end
end
