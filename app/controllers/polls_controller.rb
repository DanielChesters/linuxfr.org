# encoding: UTF-8
class PollsController < ApplicationController
  before_filter :authenticate_account!, :only => [:new, :create]
  before_filter :find_poll, :only => [:show, :vote]
  after_filter  :marked_as_read, :only => [:show], :if => :account_signed_in?
  respond_to :html, :atom

  def index
    @order = params[:order] || 'created_at'
    @polls = Poll.archived.joins(:node).order("nodes.#{@order} DESC").paginate(:page => params[:page], :per_page => 10)
    if on_the_first_page?
      poll = Poll.current
      @polls.unshift(poll) if poll
    end
    respond_with(@polls)
  end

  def show
    enforce_view_permission(@poll)
    redirect_to @poll, :status => 301 if !@poll.friendly_id_status.best?
  end

  def new
    @poll = Poll.new
    enforce_create_permission(@poll)
  end

  def create
    @poll = Poll.new
    enforce_create_permission(@poll)
    @poll.attributes = params[:poll]
    if !preview_mode && @poll.save
      redirect_to polls_url, :notice => "L'équipe de modération de LinuxFr.org vous remercie pour votre proposition de sondage"
    else
      @poll.node = Node.new
      render :new
    end
  end

  def vote
    enforce_answer_permission(@poll)
    @answer = @poll.answers.where(:position => params[:position]).first
    raise ActiveRecord::RecordNotFound unless @answer
    @answer.vote(request.remote_ip)
    redirect_to @poll, :notice => "Merci d'avoir voté pour ce sondage"
  end

protected

  def on_the_first_page?
    params[:page].to_i <= 1
  end

  def find_poll
    @poll = Poll.find(params[:id])
  end

  def marked_as_read
    current_user.read(@poll.node)
  end

  def enforce_answer_permission(poll)
    raise Canable::Transgression unless poll.answerable_by?(request.remote_ip)
  end
end
