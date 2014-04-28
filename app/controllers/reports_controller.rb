class ReportsController < ApplicationController
  def new
  end

  def create
    @start_date, @end_date = Date.parse( params[:start_date] ), Date.parse( params[:end_date] )
    @tickets = Ticket.where("created_at > ? AND finished_at < ?", @start_date, @end_date)
    if params[:generate_pdf]
      render :pdf => "Отчет с #{@start_date} по #{@end_date}",
             :disposition=> 'attachment',
             :template => "reports/_report.html.haml",
             :encoding => "utf8"
    else
      render :new
    end
  end

end
