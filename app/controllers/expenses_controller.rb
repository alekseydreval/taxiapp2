class ExpensesController < InheritedResources::Base
  
  def create
    create! do |success, failure|
      success.html { redirect_to :root, notice: 'Расходы добавлены' }
      failure.html { redirect_to :root }
    end
  end

  private
    def permitted_params
      params.permit(expense: [:amount, :expenses_type])
    end

end