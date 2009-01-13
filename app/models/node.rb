# == Schema Information
# Schema version: 20090110185148
#
# Table name: nodes
#
#  id           :integer(4)      not null, primary key
#  content_type :string(255)
#  content_id   :integer(4)
#  score        :integer(4)
#  user_id      :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#

class Node < ActiveRecord::Base
  belongs_to :user
  belongs_to :content, :polymorphic => true
  has_many :comments

  named_scope :by_date, :order => "created_at DESC"
end