require 'spec_helper'
require 'pry'

describe ApplicationController do


  describe 'user show page' do
    it 'shows all a single users loans' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      loan1=Loan.create(:loan_face_value => 1000, :loan_term => 12, :annual_rate => 10, :lender_name => "test bank 1", :user_id => user.id)
      loan2=Loan.create(:loan_face_value => 2000, :loan_term => 6, :annual_rate => 10, :lender_name => "test bank 2", :user_id => user.id)

      get "/users/#{user.slug}"

      expect(last_response.body).to include("test bank 1")
      expect(last_response.body).to include("test bank 2")

    end
  end

  describe 'index action' do
    context 'logged in' do
      it 'lets a user view only their loans if logged in' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
    
        loan1=Loan.create(:loan_face_value => 1000, :loan_term => 12, :annual_rate => 10, :lender_name => "test bank 1", :user_id => user1.id)
        

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        loan2=Loan.create(:loan_face_value => 2000, :loan_term => 6, :annual_rate => 10, :lender_name => "test bank 2", :user_id => user2.id)
        
        
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "/loans"
        expect(page.body).to include(loan1.content)
        expect(page.body).not_to include(loan2.content)
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
      it 'lets user view new loan form if logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/loans/new'
        expect(page.status_code).to eq(200)
      end

      it 'lets user create a loan if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/loans/new'
        fill_in(:loan_face_value, :with => 1000)
        fill_in(:loan_term, :with => 12)
        fill_in(:annual_rate, :with => 10)
        fill_in(:lender_name, :with => "testing create")
        
        click_button 'submit'

        user = User.find_by(:username => "becky567")
        loan = Loan.find_by(:lender_name => "testing create")
        expect(loan).to be_instance_of(Loan)
        expect(loan.user_id).to eq(user.id)
        expect(page.status_code).to eq(200)
      end

      it "does not let a user create a loan in another user's name" do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/loans/new'

        fill_in(:loan_face_value, :with => 1000)
        fill_in(:loan_term, :with => 12)
        fill_in(:annual_rate, :with => 10)
        fill_in(:lender_name, :with => "testing create of authorized user")
        click_button 'submit'

        user = User.find_by(:id=> user.id)
        user2 = User.find_by(:id => user2.id)
        loan = Loan.find_by(:lender_name => "testing create of authorized user")
        expect(loan).to be_instance_of(Loan)
        expect(loan.user_id).to eq(user.id)
        expect(loan.user_id).not_to eq(user2.id)
      end

      it 'does not let a user create a blank tweet' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/loans/new'

        fill_in(:lender_name, :with => "")
        click_button 'submit'

        expect(Loan.find_by(:lender_name => "")).to eq(nil)
        expect(page.current_path).to eq("/loans/new")
      end
    end

    context 'logged out' do
      it 'does not let user view new loan form if not logged in' do
        get '/loans/new'
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'show action' do
    context 'logged in' do
      it 'displays a single loan' do

        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        loan=Loan.create(:loan_face_value => 1000, :loan_term => 12, :annual_rate => 10, :lender_name => "test bank 1", :user_id => user.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit "/loans/#{loan.id}"
        expect(page.status_code).to eq(200)
        expect(page.body).to include("Delete Loan")
        expect(page.body).to include(loan.loan_face_value)
        expect(page.body).to include("Edit Loan")
      end
    end

    context 'logged out' do
      it 'does not let a user view a loan' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        loan=Loan.create(:loan_face_value => 1000, :loan_term => 12, :annual_rate => 10, :lender_name => "test bank 1", :user_id => user.id)
        get "/loans/#{loan.id}"
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'edit action' do
    context "logged in" do
      it 'lets a user view loan edit form if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        loan=Loan.create(:loan_face_value => 1000, :loan_term => 12, :annual_rate => 10, :lender_name => "test bank 1", :user_id => user.id)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/loans/1/edit'
        expect(page.status_code).to eq(200)
        expect(page.body).to include(loan.lender_name)
      end

      it 'does not let a user edit a loan they did not create' do
        
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        loan1=Loan.create(:loan_face_value => 1000, :loan_term => 12, :annual_rate => 10, :lender_name => "test bank 1", :user_id => user1.id)
        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        loan2=Loan.create(:loan_face_value => 2000, :loan_term => 6, :annual_rate => 10, :lender_name => "test bank 2", :user_id => user2.id)
        
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "/loans/#{loan2.id}/edit"
        expect(page.current_path).to include('/loans')
      end

      it 'lets a user edit their own loan if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        loan=Loan.create(:loan_face_value => 2000, :loan_term => 6, :annual_rate => 10, :lender_name => "test bank 2", :user_id => user.id)

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/loans/1/edit'

        fill_in(:loan_face_value, :with => 1000)
        fill_in(:loan_term, :with => 12)
        fill_in(:annual_rate, :with => 10)
        fill_in(:lender_name, :with => "testing edit of authorized user")

        click_button 'submit'
        expect(Loan.find_by(:lender_name => "testing edit of authorized user")).to be_instance_of(Loan)
        expect(Loan.find_by(:lender_name => "test bank 2")).to eq(nil)
        expect(page.status_code).to eq(200)
      end

      it 'does not let a user edit a text with blank content' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        loan=Loan.create(:loan_face_value => 1234, :loan_term => 6, :annual_rate => 10, :lender_name => "test no blank submit", :user_id => user.id)
        
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/loans/1/edit'

        fill_in(:content, :with => "")


        fill_in(:loan_face_value, :with => "")
        

        click_button 'submit'
        expect(Loan.find_by(:lender_name => "test no blank submit").loan_face_value).to eq(1234)
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
      it 'lets a user delete their own loan if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        loan=Loan.create(:loan_face_value => 1000, :loan_term => 12, :annual_rate => 10, :lender_name => "test bank 1", :user_id => user.id)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit 'loans/1'
        click_button "Delete Loan"
        expect(page.status_code).to eq(200)
        expect(Loan.find_by(:lender_name => "test bank 1")).to eq(nil)
      end

      it 'does not let a user delete a loan they did not create' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        loan1=Loan.create(:loan_face_value => 1000, :loan_term => 12, :annual_rate => 10, :lender_name => "test bank 1", :user_id => user1.id)
        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        loan2=Loan.create(:loan_face_value => 2000, :loan_term => 6, :annual_rate => 10, :lender_name => "test bank 2", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "loans/#{loan2.id}"
        
        
        
        expect(page.current_path).to eq('/')
      end
    end

    context "logged out" do
      it 'does not load let user delete a loan if not logged in' do
        loan=Loan.create(:loan_face_value => 1000, :loan_term => 12, :annual_rate => 10, :lender_name => "test bank 1", :user_id => 1)
        visit '/loans/1'
        expect(page.current_path).to eq("/login")
      end
    end
  end
end
