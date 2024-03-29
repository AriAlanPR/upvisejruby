class ApplicationController < ActionController::Base
    include ApplicationHelper
    require 'java'
    require 'UpviseClient.jar' #import upvise java library
    protect_from_forgery with: :null_session

    def upvise_user
        'dmceldow@hotmail.com'
    end

    def upvise_password
        'MAcent5768'
    end

    #upvise client loading, using uv as upvise
    def uv_client
        Java::ComUpviseClient
    end

    def uv_client_query
        uv_client::Query
    end

    def uv_token 
        uv_client_query.login(upvise_user, upvise_password)
    end

    def uv_query 
        uv_client_query.new(uv_token)
    end
end
