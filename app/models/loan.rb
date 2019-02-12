require './config/environment'
class Loan < ActiveRecord::Base 
  belongs_to :user 
  
  validates :loan_face_value, numericality: {greater_than: 0}
  validates :loan_term, numericality: {greater_than: 0}
  validates :annual_rate, numericality: {greater_than: 0}
  validates :annual_rate, numericality: {less_than: 100}
  validates :lender_name, presence: true 

end 