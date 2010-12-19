module StaticHelper
  def helperify(txt)
    txt.gsub(/\{\{([a-z_]+)\}\}/) { send "helper_#{$1}" }.html_safe
  end

  def helper_admin_list
    Account.admin.all.map { |a| user = a.user; link_to user.name, user }.to_sentence
  end

  def helper_moderator_list
    Account.moderator.all.map { |a| user = a.user; link_to user.name, user }.to_sentence
  end

  def helper_reviewer_list
    Account.reviewer.all.map { |a| user = a.user; link_to user.name, user }.to_sentence
  end

  def helper_responses_list
    content_tag(:ul, Response.all.map { |r| content_tag(:li, content_tag(:pre, r.content)) }.join.html_safe)
  end
end
