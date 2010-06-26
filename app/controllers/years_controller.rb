class YearsController < ApplicationController
  def index
    @years = Year.all
    @terms = Term.all
  end
  
  def create
    @year = Year.add
    render :action => "create.rjs"
  end

  def make_current
    @term = Term.find params[:id]
    @term.make_current!
    render :action => "make_current.rjs"
  end
  
  def create_term
    @term = Term.create params[:term]
  end
  
  def destroy_term
    if not Mark.find_by_term_id params[:id]
      @term = Term.find params[:id]
      @term.destroy
    end
    render :action => "destroy_term.rjs"
  end
end
