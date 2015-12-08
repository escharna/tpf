class SubEventsController < ApplicationController
  before_action :set_sub_event, only: [:show, :edit, :update, :destroy, :sign_up, :remove_user_from_task, :calculate_hours, :edit_attendance, :complete_task]
  after_action :notify, only: [:sign_up, :task_remove]
  #before_action :check, only: [:add_user_to_task]

  load_and_authorize_resource
  # GET /sub_events
  # GET /sub_events.json
  def index
    @sub_events = SubEvent.all
  end

  def notify
    if action_name == 'sign_up'
      notification_type = 'Task Registered'
      body = current_user.fname + ' has registered for ' +  @sub_event.name
    elsif action_name == 'task_remove'
      notification_type = 'Task Unregistered'
      body = current_user.fname + ' has unregistered from ' +  @sub_event.name
    end

    notification = Notification.create(notification_type: notification_type, body: body)

    User.where(role: 'admin').each do |u|
      #notification.users << u
      UserNotification.create(user_id: u.id, notification_id: notification.id, read: false)
    end

  end

  def complete_task
    if @sub_event.update(:completed_at => Time.now)
      @sub_event.event.completes unless @sub_event.event.incomplete_tasks?
      response = {notice: "Task has been completed."}
    else
      response = {alert: "Task could not be completed"}
    end
    if @sub_event.event.completed_at.nil?
      redirect_to event_path(@sub_event.event), response
    else
      redirect_to events_path, response
    end
  end

  def task_remove
    #hours = ((@sub_event.start_time-Time.now)/1.hour).round
    #if hours <= 24
      #response = {alert: "This task begins in #{hours} hours.  You must give at least 24 hours notice to remove yourself from a task!"}
    #else
      @sub_event.users.delete(current_user)
      response = {notice: "You have been removed from this task."}
    #end
    redirect_to event_path(@sub_event.event), response
  end

  def roster
    @roster = @sub_event.users
  end

  def add_user_to_task
    @user = User.find(params[:user_id])
      if !@sub_event.users.include?(@user) && @user.is_enduser? && !@sub_event.is_full?(@user.role)
        @sub_event.users << @user
        @sub_event.save
        response = {notice: "User added to task."}
      else
        msg = @sub_event.is_full?(@user.role) ? "Task is full for #{@user.role} users!" : "User already belongs to task!"
        response =  {alert: msg }
      end
      redirect_to roster_path(@sub_event), response
  end

  def edit_attendance
    sub = UserSubEvent.find_by(sub_event_id: params[:id], user_id: params[:attendee_id])
    sub.attended = params[:attended]

    factor =  params[:attended] == 'true' ? 1 : -1
    diff = (@sub_event.end_time - @sub_event.start_time)/3600

    if sub.save
      user = User.find(params[:attendee_id])
      user.increment_hours(diff*factor)
      message = {notice: "#{user.full_name}'s hours has been updated to #{user.hours} hours"}
    else
      message = {alert: "Attendance could not be marked"}
    end
    redirect_to roster_path(@sub_event), message
  end

  def calculate_hours
    @user = User.find(params[:user_id])
    @hours = (@sub_event.end_time - @sub_event.start_time)/3600
    @user.hours += @hours
    if @user.save
      response = {notice: "#{@user.fname + ' ' + @user.lname} has had #{@hours} hours added to their account."}
    else
      response = {notice: "There was a problem saving."}
    end
    redirect_to roster_path(@sub_event), response
  end

  def remove_user_from_task
    @sub_event.users.delete(params[:user_id])
    response = {notice: "You have been removed from this task."}
    #end
    redirect_to roster_path(@sub_event), response
  end

  def sign_up
    if @sub_event.volunteer_count(current_user.role) < @sub_event.try(current_user.role + '_num')

      if !@sub_event.users.include?(current_user)
        @sub_event.users << current_user
        @sub_event.save
        response = {notice: "You've been added to this task!"}
      else
        response =  {alert: "You've already been added to this task!"}
      end
      redirect_to event_path(@sub_event.event), response
    else
      redirect_to event_path(@sub_event.event), alert: "This task is already full!"
    end
  end

  def show

  end

  # GET /sub_events/new
  def new
    @event = Event.find(params[:event_id])
    @sub_event = SubEvent.new
    @sub_event.event_id = params[:event_id]
  end

  # GET /sub_events/1/edit
  def edit
    @event = Event.find(params[:event_id])
  end

  # POST /sub_events
  # POST /sub_events.json
  def create
    @sub_event = SubEvent.new(sub_event_params)
    @sub_event.event_id = params[:event_id]

    respond_to do |format|
      if @sub_event.save
        format.html { redirect_to event_path(params[:event_id]), notice: 'Sub event was successfully created.' }
        format.json { render :show, status: :created, location: @sub_event }
      else
        format.html { render :new }
        format.json { render json: @sub_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sub_events/1
  # PATCH/PUT /sub_events/1.json
  def update
    respond_to do |format|
      if @sub_event.update(sub_event_params)
        format.html { redirect_to events_path, notice: 'Sub event was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /sub_events/1
  # DELETE /sub_events/1.json
  def destroy
    @sub_event.destroy
    respond_to do |format|
      format.html { redirect_to events_path, notice: 'Sub event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sub_event
      #@event = Event.find(params[:event_id])
      @sub_event = SubEvent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sub_event_params
      params.require(:sub_event).permit(:sub_event_type_id, :event_id, :name, :intern_num, :staff_num, :community_num, :start_time, :end_time)
    end
end
