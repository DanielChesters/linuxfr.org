# encoding: UTF-8
#
# == Schema Information
#
# Table name: news
#
#  id           :integer(4)      not null, primary key
#  state        :string(255)     default("draft"), not null
#  title        :string(255)
#  cached_slug  :string(255)
#  body         :text
#  second_part  :text
#  moderator_id :integer(4)
#  section_id   :integer(4)
#  author_name  :string(255)     not null
#  author_email :string(255)     not null
#  created_at   :datetime
#  updated_at   :datetime
#

require 'spec_helper'

describe News do
  before(:each) do
    User.delete_all
    Account.delete_all
    News.delete_all
  end

  context "when created in redaction" do
    let(:news) { News.create_for_redaction(Factory.create :writer) }

    it "has two paragraphs, one in each part" do
      news.should have(2).paragraphs
      news.paragraphs.in_first_part.should have(1).item
      news.paragraphs.in_second_part.should have(1).item
    end

    it "has a body and a second part" do
      news.body =~ /Vous pouvez éditer/
      news.second_part =~ /Vous pouvez éditer/
    end

    it "has an updated body when a paragraph is added" do
      para = news.paragraphs.first
      para.wiki_body = "Paragraphe un\n\nparagraphe deux\n"
      para.update_by(Factory.create :moderator)
      news.should have(3).paragraphs
      news.paragraphs.in_first_part.should have(2).item
      news.body =~ /Paragraphe un<\/p>.*<p>paragraphe deux/
    end
  end
end
