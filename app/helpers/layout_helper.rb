module LayoutHelper

  def body_attr
    classes = %w(js-off)
    classes << 'logged' if current_user
    classes << current_user.role if current_user
    classes << Rails.env if Rails.env != 'production'
    { :class => classes.join(' '), :id => "#{controller.controller_name}-#{controller.action_name}" }
  end

  def check_js
    javascript_tag "document.body.className = document.body.className.replace('js-off', 'js-on');"
  end

  def logo
    img = Logo.image
    content_tag(:h1, :title => "Le logo de LinuxFr.org", :style => "background-image: url('#{img}');") do
      link_to "LinuxFr.org", '/'
    end
  end

  def common_js
    jquery         =  'http://code.jquery.com/jquery-1.4.2.min.js'
    jquery_plugins = %w(jquery.nano jquery.autocomplete jquery.markitup jquery.hotkeys jquery.notice)
    dlfp_plugins   = %w(dlfp.chat dlfp.nested_fields dlfp.toolbar)
    others         = %w(markitup-markdown rails application)
    local_js       = jquery_plugins + dlfp_plugins + others
    javascript_include_tag(jquery) + javascript_include_tag(*local_js)
  end

end
