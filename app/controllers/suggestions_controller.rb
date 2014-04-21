class SuggestionsController < InheritedResources::Base
  load_resource except: :create
  
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
      params.permit(suggestion: [:user_id])
    end
end
