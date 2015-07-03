class UsersController < ApplicationController

	before_action :set_user, only: [:show, :edit, :update, :destroy]

	before_action :authenticate_user!

	load_and_authorize_resource

	def dashboard
	
	end

	def index

		@users = User.all

	end

	def show
		@sub_events = UserSubEvent.where(user_id: @user)
		@notes = VolunteerNote.joins("INNER JOIN `users` ON `users`.`id` = `volunteer_notes`.`created_by_user_id`").select("*")
	end

	def new
    	@user = User.new
  	end

  	def edit

  	end

  	def create
    @user = User.create(user_params)

    respond_to do |format|
	      if @user.save
	        format.html { redirect_to users_path, notice: 'Volunteer note was successfully created.' }
	        format.json { render :show, status: :created, location: @users }
	      else
	        format.html { render :new }
	        format.json { render json: @users.errors, status: :unprocessable_entity }
	      end
    	end
  	end

	def update

    	respond_to do |format|
      		if @user.update(user_params)
        		format.html { redirect_to @user, notice: 'User Profile was successfully updated.' }
        		format.json { render :show, status: :ok, location: @user }
      		else
        		format.html { render :edit }
        		format.json { render json: @user.errors, status: :unprocessable_entity }
      		end
    	end
	end

	def destroy
	    @user.destroy
	    respond_to do |format|
	      format.html { redirect_to users_url, notice: 'User was successfully deleted.' }
	      format.json { head :no_content }
	    end
  	end

	private
    	# Use callbacks to share common setup or constraints between actions.
    	def set_user
      		@user = User.find(params[:id])
    	end

    	# Never trust parameters from the scary internet, only allow the white list through.
    	def user_params
      		params.require(:user).permit(:fname, :lname, :email, :password, :password_confirmation, :current_password, :role)
    	end
  	
end