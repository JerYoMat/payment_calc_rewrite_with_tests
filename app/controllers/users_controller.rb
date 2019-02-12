require 'pry'
class UsersController < ApplicationController

    get '/signup' do 
      @user = User.new 
      erb  :'users/new' 
    end 

    post '/signup' do 
        @user = User.new(username: params[:username], email: params[:email], password: params[:password])
        if @user.save
          session[:user_id] = @user.id 
          redirect to '/loans'
        else 
          erb :'users/new'
        end 
    end 

    get '/users' do 
    end 

    get '/users/:id' do 
    end 

    get '/users/:id/edit' do 
    end 

    patch '/users/:id' do 
    end 

    delete '/users/:id' do 
    end 

end 

