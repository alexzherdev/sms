class ClassRoomsController < ApplicationController
  def index
    @class_rooms = ClassRoom.all
    @subjects = Subject.all
  end

  def new
    @class_room = ClassRoom.new
  end
  
  def edit
    @class_room = ClassRoom.find params[:id]
    render :partial => "form", :locals => { :url => class_room_path(@class_room), :method => "PUT" }
  end
  
  def create
    @class_room = ClassRoom.create params[:class_room]
    redirect_to class_rooms_path
  end

  def destroy
    @class_room = ClassRoom.find params[:id]
    @class_room.destroy
    redirect_to class_rooms_path
  end

end
