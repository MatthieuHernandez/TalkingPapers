require 'net/http'
require 'json'

class UsersController < ApplicationController
    include ApplicationHelper
    before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
    before_action :correct_user,     only: [:edit, :update]
    #before_action :admin_user, only: :destroy
    def index
        @users = User.paginate(page: params[:page])
    end

    def show
        @user = User.find(params[:id])
        @user_articles = @user.articles_with_notes.distinct
        @current_user = current_user
    end

    def new
        @user = User.new
    end

    def create
        @user = User.new(user_params)
        if !@user.name.blank?
            @user.admin = false
            if @user.save
                @user.send_activation_email
                flash[:info] = 'Please check your email to activate your account.'
                redirect_to root_url
            else
                render user_path(user)
            end
        else
            flash.now[:danger] = "Username connot be blank."
            render 'new'
        end
    end

    def get_or_create_from_provider
        user = User.find_by(email: params[:user][:email])
        if user.nil?
            @user = User.new(user_params_from_provider)
            @user.admin = false
            @user.activated = true
            @user.password = random_password
            if verify_provider && @user.save!
                log_in @user
                ajax_redirect_to(user_path(@user))
            else
                ajax_redirect_to(root_path)
                flash[:danger] = "#{params[:user][:email]} connection failed"
            end
        else
            if verify_provider
                @user = user
                log_in @user
                ajax_redirect_to(user_path(@user))
            else
                ajax_redirect_to(root_path)
                flash[:danger] = "#{params[:user][:email]} connection failed"
            end
        end
    end

    def edit
        @user = User.find(params[:id])
    end

    def update
        @user = User.find(params[:id])
        if(params[:user][:avatar].present?)
            image = MiniMagick::Image.new(params[:user][:avatar].tempfile.path)
            image.resize "80x80!"
        end
        if @user.update(user_params)
            flash[:success] = 'Profile updated'
            redirect_to user_path
        else
            redirect_to edit_user_path(@user.id)
        end
    end

    def delete_avatar
        @user = User.find(params[:id])
        @user.avatar.purge
        redirect_to edit_user_path(@user.id)
    end

    def destroy
        if current_user && current_user.id == session[:user_id]
            if !current_user.provider.blank? or current_user.authenticate(params[:session][:password])
                User.find(current_user.id).destroy
                destroy_notes
                flash[:success] = 'Account deleted'
                redirect_to root_url
            else
                flash.now[:danger] = 'Invalid password'
                render 'delete'
            end
        else
            flash.now[:danger] = 'Wrong account'
            redirect_to root_url
        end
    end

    private

    def user_params
        params.require(:user).permit(:avatar, :name, :email, :password, :password_confirmation)
    end

    def user_params_from_provider
        params.require(:user).permit(:name, :email, :provider, :external_id, :picture_link, :access_token)
    end

    def verify_provider
        case params[:user][:provider]
        when 'Facebook'
            return verify_facebook(params[:user][:external_id], params[:user][:access_token])
        when 'Google'
            return verify_google(params[:user][:external_id], params[:user][:access_token])
        else
            return false
        end
    end

    def verify_facebook(id, token)
        begin
            url = URI.parse("https://graph.facebook.com/me?access_token=#{token}")
            res = Net::HTTP.get_response(url)
            result = JSON.parse(res.body)
            if result["error"] == nil && result["id"] == id
                return true
            end
        rescue
        end
        return false
     end
    
    def verify_google(id, token)
        begin
            url = URI.parse("https://oauth2.googleapis.com/tokeninfo?id_token=#{token}")
            res = Net::HTTP.get_response(url)
            result = JSON.parse(res.body)
            if result["error"] == nil && result["sub"] == id
                return true
            end
        rescue
        end
        return false
    end


    # Confirms a logged-in user.
    def logged_in_user
        unless logged_in?
            store_location
            flash[:danger] = 'Please log in.'
            redirect_to login_url
        end
    end

    # Confirms the correct user.
    def correct_user
        @user = User.find(params[:id])
        redirect_to(root_url) unless current_user?(@user)
    end

    # Confirms an admin user.
    def admin_user
        redirect_to(root_url) unless current_user.admin?
    end

    # Destroy all user notes.
    def destroy_notes
        notes = Note.where('user_id = ? OR username IS ?', current_user.id, nil)
        notes.each do |note|
            if note.is_public == true
                note.update(username: nil)
                note.update(is_anon: true)
            else
                note.destroy
            end
        end
    end

    def random_password(length = 10)
        chars = ('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a
        chars.sort_by { rand }.join[0...length]
    end

end
