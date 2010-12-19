# encoding: UTF-8
class ApplicationController < ActionController::Base
  include Canable::Enforcers

  protect_from_forgery
  before_filter :seo_filter
  helper_method :mobile?, :url_for_content, :current_user

  VALID_ORDERS = %w(created_at score interest last_commented_at)

protected

  def seo_filter
    request.session_options[:secure] = request.ssl?
    @title         = %w(LinuxFr.org)
    @author        = nil
    @keywords      = %w(Linux Logiciel Libre GNU Free Software Actualité Forum Communauté)
    @description   = "L'actualité de Linux et du Logiciel Libre"
    @feeds         = {}
    @last_comments = Comment.footer
    @popular_tags  = Tag.footer
    @friend_sites  = FriendSite.scoped
  end

  def mobile?
    request.subdomains.first == 'm'
  end

### Content ###

  def redirect_to_content(content)
    redirect_to url_for_content(content)
  end

  def url_for_content(content)
    case content
    when Diary then content.new_record? ? "/journaux" : url_for([content.owner, content])
    when News  then content.new_record? ? "/news" : url_for(content)
    when Post  then url_for([content.forum, content])
               else url_for(content)
    end
  end

  def preview_mode
    @preview_mode = (params[:commit] == 'Prévisualiser')
  end

### Authentication & authorizations ###

  def current_user
    current_account.try(:user)
  end

  def admin_required
    return if current_account && current_account.admin?
    store_location!(:account)
    redirect_to new_account_session_url, :alert => "Vous ne possédez pas les droits nécessaires pour accéder à cette partie du site"
  end

  def amr_required
    return if current_account && current_account.amr?
    store_location!(:account)
    redirect_to new_account_session_url, :alert => "Vous ne possédez pas les droits nécessaires pour accéder à cette partie du site"
  end

  def writer_required
    return if current_account && (current_account.writer? || current_account.amr?)
    store_location!(:account)
    redirect_to new_account_session_url, :alert => "Vous ne possédez pas les droits nécessaires pour accéder à cette partie du site"
  end

  def enforce_view_permission(resource)
    raise Canable::Transgression unless resource.viewable_by?(current_account)
  end

  def store_location!(scope)
    session[:"#{scope}_return_to"] = url_for() if request && request.get?
  end
end
