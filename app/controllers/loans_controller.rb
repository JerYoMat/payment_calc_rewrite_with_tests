class LoansController < ApplicationController
    get '/loans' do 
 
      if logged_in?
        @loans = Loan.where(:user_id => current_user.id) || []
       
        erb :'loans/index'
      else 
        redirect to '/login'
      end 
    end 

    get '/loans/new' do
      if logged_in? 
        @loan = Loan.new 
        erb :'loans/new'
      else 
        redirect to '/login'
      end 
    end 

    post '/loans' do 
   
      @loan = current_user.loans.build(params)

      @loan.save 
      redirect to "/loans/#{@loan.id}"
    end 

    get '/loans/:id' do 
      @loan = Loan.find(params[:id])
      erb :'loans/show'
    end 

    get '/loans/:id/edit' do 
      @loan = Loan.find(params[:id])
      erb :'loans/edit'
    end 

    patch '/loans/:id' do 
      @loan = Loan.find(params[:id])
      @loan.update_attributes(params)
      redirect to '/loans'
    end 

    delete '/loans/:id/delete' do 
      @loan = Loan.find(params[:id])
      @loan.destroy 
      redirect '/loans'
    end 

    private 
    def owning_user?
       @loan.user == current_user ? true : false 
    end 

    def current_user
        if session[:user_id]
          @current_user ||= User.find_by(id: session[:user_id])  # Same as @current_user = @current_user || User.find_by(id: session[:user_id])
        end 
      end

end 