class SessionsController < ApplicationController

  get '/login' do 
    if session[:user_id]
      redirect to '/loans'
    else 
      erb :'sessions/new'
    end 
  end 

  post '/login' do
    @user = User.find_by(:username => params[:username])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect to '/loans'
    else
      binding.pry
      redirect to '/login'
    end
  end 

  get '/logout' do
    if session[:user_id]
      session.destroy
      redirect to '/login'
    else
      redirect to '/'
    end
  end

end 