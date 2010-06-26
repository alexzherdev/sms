class SubjectsController < ApplicationController
  def index
    @subjects = Subject.all
    @teachers = Teacher.all
  end
  
  def new
    @subject = Subject.new
    render :partial => "form", :locals => { :url => subjects_path, :method => "POST" }
  end
  
  def create
    @subject = Subject.create params[:subject]
    render :action => "create.rjs", :status => @subject.valid? ? 200 : 403
  end
  
  def destroy
    if not ScheduleItem.find_by_subject_id params[:id]
      @subject = Subject.find(params[:id])
      @subject.destroy
    end
    render :action => "destroy.rjs"
  end
  
  def edit
    @subject = Subject.find params[:id]
    render :partial => "form", :locals => { :url => subject_path(@subject), :method => "PUT" }
  end
  
  def update
    @subject = Subject.find params[:id]
    @subject.update_attributes params[:subject]
    render :action => "update.rjs", :status => @subject.valid? ? 200 : 403
  end
  
  def import
    importer = SubjectsImporter.new params[:file].read
    subjects = importer.parse
    Subject.create subjects
    redirect_to subjects_url
  end
end
