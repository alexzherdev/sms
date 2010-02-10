class ClassRoomsController < ApplicationController
  def index
    @class_rooms = ClassRoom.all
    @subjects = Subject.all
  end

  def new
    @class_room = ClassRoom.new
    @unused_subjects = Subject.all
    render :partial => "form", :locals => { :url => class_rooms_path, :method => "POST" }
  end
  
  def create
    @class_room = ClassRoom.create params[:class_room]
    @unused_subjects = Subject.all - @class_room.subjects
    render :action => "create.rjs", :status => @class_room.valid? ? 200 : 403
  end
  
  def edit
    @class_room = ClassRoom.find params[:id]
    @unused_subjects = Subject.all - @class_room.subjects
    render :partial => "form", :locals => { :url => class_room_path(@class_room), :method => "PUT" }
  end
  
  def update
    @class_room = ClassRoom.find params[:id]
    @class_room.update_attributes params[:class_room]
    @unused_subjects = Subject.all - @class_room.subjects
    render :action => "update.rjs", :status => @class_room.valid? ? 200 : 403
  end

  def destroy
    @class_room = ClassRoom.find params[:id]
    @class_room.destroy
    redirect_to class_rooms_path
  end

end
