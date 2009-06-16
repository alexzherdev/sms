class ClassRoomsController < ApplicationController
  def index
    @class_rooms = ClassRoom.all
  end

  def new
    @class_room = ClassRoom.new
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
