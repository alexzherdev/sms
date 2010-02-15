module YearsHelper
  def year_collection(years)
    collect_values(years, [:id, :start_year, :end_year, :full_name])
  end
  
  def term_collection(terms)
    terms.collect do |t|
      [ t.id, t.start_date.date_format, t.end_date.date_format, t.year_id, t.current?, term_name(t) ]
    end
  end
end
