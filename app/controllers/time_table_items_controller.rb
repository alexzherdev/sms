class TimeTableItemsController < ApplicationController
  def index
    @items = TimeTableItem.all
  end

  def create
    @item = TimeTableItem.add(params[:item_type].to_i) 
    @index = TimeTableItem.lessons.count
    render :action => "create.rjs"
  end

  def destroy
    if not ScheduleItem.find_by_time_table_item_id params[:id]
      @item = TimeTableItem.find params[:id]
      @item.destroy_and_shift
    end
    render :action => "destroy.rjs"
  end

  def settings
    render :partial => "settings"
  end
  
  def update_settings
    Settings["lessons_start"] = Time.parse(params[:settings][:lessons_start] + " UTC")
    Settings["lesson_length"] = params[:settings][:lesson_length].to_i
    Settings["short_break"] = params[:settings][:short_break].to_i
    Settings["long_break"] = params[:settings][:long_break].to_i
    
    TimeTableItem.recalculate_times
    
    redirect_to time_table_items_path
  end
end
