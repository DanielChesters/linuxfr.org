# == Schema Information
# Schema version: 20090120005239
#
# Table name: news
#
#  id          :integer(4)      not null, primary key
#  state       :string(255)     default("draft"), not null
#  title       :string(255)
#  body        :text
#  second_part :text
#  section_id  :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

class News < ActiveRecord::Base
  belongs_to :section
  has_many :links
end
