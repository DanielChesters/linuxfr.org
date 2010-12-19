require 'spec_helper'

describe "Relevance" do
  before(:each) do
    User.delete_all
    Account.delete_all
    $redis.flushdb
  end

  let(:account) { Factory(:account) }
  let(:writer)  { Factory(:writer) }
  let(:comment) { Factory(:comment, :user_id => writer.id) }

  it "creates an instance when an account votes for a comment" do
    comment.vote_for(account)
    comment.reload.score.should == 1
  end

  it "creates an instance when an account votes against" do
    comment.vote_against(account)
    comment.reload.score.should == -1
  end

  it "can't be changed by an account if he changes his mind" do
    comment.vote_for(account)
    comment.vote_against(account)
    comment.reload.score.should == 1
  end

  it "is idempotent" do
    3.times { comment.vote_for(account) }
    comment.reload.score.should == 1
  end

  it "decrements the number of votes for the account" do
    account.update_attribute(:nb_votes, 10)
    comment.vote_for(account)
    account.reload.nb_votes.should == 9
  end
end
