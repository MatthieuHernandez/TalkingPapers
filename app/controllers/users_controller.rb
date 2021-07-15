class UsersController < ApplicationController
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
        @user.admin = false
        if @user.save
            @user.send_activation_email
            flash[:info] = 'Please check your email to activate your account.'
            redirect_to root_url
        else
            render 'new'
        end
    end

    def get_or_create_from_provider
        puts'======================================================'
        puts 'get_or_create_from_provider'
        puts'======================================================'
        redirect_to root_url
    end

    def edit
        @user = User.find(params[:id])
    end

    def update
        @user = User.find(params[:id])
        if @user.update(user_params)
            flash[:success] = 'Profile updated'
            redirect_to @user
        else
            render 'edit'
        end
    end

    def destroy
        if current_user && current_user.id == session[:user_id]
            if current_user.authenticate(params[:session][:password])
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
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
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

end
