require 'spec_helper'
require 'pry'

describe ApplicationController do

  

  describe 'user show page' do
    it 'shows all a single users loans' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      tweet1 = Tweet.create(:content => "tweeting!", :user_id => user.id)
      tweet2 = Tweet.create(:content => "tweet tweet tweet", :user_id => user.id)
      get "/users/#{user.slug}"

      expect(last_response.body).to include("tweeting!")
      expect(last_response.body).to include("tweet tweet tweet")

    end
  end

  describe 'index action' do
    context 'logged in' do
      it 'lets a user view the loans index if logged in' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet1 = Tweet.create(:content => "tweeting!", :user_id => user1.id)

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        tweet2 = Tweet.create(:content => "look at this tweet", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "/loans"
        expect(page.body).to include(tweet1.content)
        expect(page.body).to include(tweet2.content)
      end
    end

    context 'logged out' do
      it 'does not let a user view the loans index if not logged in' do
        get '/loans'
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'new action' do
    context 'logged in' do
      it 'lets user view new tweet form if logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/loans/new'
        expect(page.status_code).to eq(200)
      end

      it 'lets user create a tweet if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/loans/new'
        fill_in(:content, :with => "tweet!!!")
        click_button 'submit'

        user = User.find_by(:username => "becky567")
        tweet = Tweet.find_by(:content => "tweet!!!")
        expect(tweet).to be_instance_of(Tweet)
        expect(tweet.user_id).to eq(user.id)
        expect(page.status_code).to eq(200)
      end

      it 'does not let a user tweet from another user' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/loans/new'

        fill_in(:content, :with => "tweet!!!")
        click_button 'submit'

        user = User.find_by(:id=> user.id)
        user2 = User.find_by(:id => user2.id)
        tweet = Tweet.find_by(:content => "tweet!!!")
        expect(tweet).to be_instance_of(Tweet)
        expect(tweet.user_id).to eq(user.id)
        expect(tweet.user_id).not_to eq(user2.id)
      end

      it 'does not let a user create a blank tweet' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/loans/new'

        fill_in(:content, :with => "")
        click_button 'submit'

        expect(Tweet.find_by(:content => "")).to eq(nil)
        expect(page.current_path).to eq("/loans/new")
      end
    end

    context 'logged out' do
      it 'does not let user view new tweet form if not logged in' do
        get '/loans/new'
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'show action' do
    context 'logged in' do
      it 'displays a single tweet' do

        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Tweet.create(:content => "i am a boss at tweeting", :user_id => user.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit "/loans/#{tweet.id}"
        expect(page.status_code).to eq(200)
        expect(page.body).to include("Delete Tweet")
        expect(page.body).to include(tweet.content)
        expect(page.body).to include("Edit Tweet")
      end
    end

    context 'logged out' do
      it 'does not let a user view a tweet' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Tweet.create(:content => "i am a boss at tweeting", :user_id => user.id)
        get "/loans/#{tweet.id}"
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'edit action' do
    context "logged in" do
      it 'lets a user view tweet edit form if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Tweet.create(:content => "tweeting!", :user_id => user.id)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/loans/1/edit'
        expect(page.status_code).to eq(200)
        expect(page.body).to include(tweet.content)
      end

      it 'does not let a user edit a tweet they did not create' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet1 = Tweet.create(:content => "tweeting!", :user_id => user1.id)

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        tweet2 = Tweet.create(:content => "look at this tweet", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "/loans/#{tweet2.id}/edit"
        expect(page.current_path).to include('/loans')
      end

      it 'lets a user edit their own tweet if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Tweet.create(:content => "tweeting!", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/loans/1/edit'

        fill_in(:content, :with => "i love tweeting")

        click_button 'submit'
        expect(Tweet.find_by(:content => "i love tweeting")).to be_instance_of(Tweet)
        expect(Tweet.find_by(:content => "tweeting!")).to eq(nil)
        expect(page.status_code).to eq(200)
      end

      it 'does not let a user edit a text with blank content' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Tweet.create(:content => "tweeting!", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/loans/1/edit'

        fill_in(:content, :with => "")

        click_button 'submit'
        expect(Tweet.find_by(:content => "i love tweeting")).to be(nil)
        expect(page.current_path).to eq("/loans/1/edit")
      end
    end

    context "logged out" do
      it 'does not load -- instead redirects to login' do
        get '/loans/1/edit'
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'delete action' do
    context "logged in" do
      it 'lets a user delete their own tweet if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Tweet.create(:content => "tweeting!", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit 'loans/1'
        click_button "Delete Tweet"
        expect(page.status_code).to eq(200)
        expect(Tweet.find_by(:content => "tweeting!")).to eq(nil)
      end

      it 'does not let a user delete a tweet they did not create' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet1 = Tweet.create(:content => "tweeting!", :user_id => user1.id)

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        tweet2 = Tweet.create(:content => "look at this tweet", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "loans/#{tweet2.id}"
        click_button "Delete Tweet"
        expect(page.status_code).to eq(200)
        expect(Tweet.find_by(:content => "look at this tweet")).to be_instance_of(Tweet)
        expect(page.current_path).to include('/loans')
      end
    end

    context "logged out" do
      it 'does not load let user delete a tweet if not logged in' do
        tweet = Tweet.create(:content => "tweeting!", :user_id => 1)
        visit '/loans/1'
        expect(page.current_path).to eq("/login")
      end
    end
  end
end
