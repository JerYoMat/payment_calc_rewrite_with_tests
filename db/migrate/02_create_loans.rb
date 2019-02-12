class CreateLoans < ActiveRecord::Migration[4.2]
  def change
    create_table :loans do |t|
      t.belongs_to :user
      t.float :loan_face_value
      t.float :loan_term
      t.float :annual_rate
      t.float :total_amount
      t.string :lender_name 
      t.timestamps
    end
  end

end
