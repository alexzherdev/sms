class ScheduleItemsController < ApplicationController
  def index
    @schedule_items = ScheduleItem.all
  end
end
