class SuggestionsController < InheritedResources::Base
  load_resource except: :create

  def create
    create!(notice: "Вы предложили поездку"){ ticket_path(@suggestion.ticket) }
  end
  
  def accept
    @suggestion.accept
    redirect_to :back
  end

  def reject
    @suggestion.reject
    redirect_to :back
  end

  private
    def permitted_params
      params.permit(suggestion: [:ticket_id, :driver_id])
    end
end
