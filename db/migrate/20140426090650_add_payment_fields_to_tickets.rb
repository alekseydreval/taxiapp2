class AddPaymentFieldsToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :payment_amount, :integer
    add_column :tickets, :payment_method, :string
    add_column :tickets, :payment_tip, :integer
  end
end
