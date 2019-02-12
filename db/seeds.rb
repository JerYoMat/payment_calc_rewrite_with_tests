user = User.create(:username => "becky567", :email => "starz@aol.com", :password_digest => BCrypt::Password.create("kittens"))
loan1=Loan.create(:loan_face_value => 1000, :loan_term => 12, :annual_rate => 10, :lender_name => "test bank 1", :user_id => user.id)
loan2=Loan.create(:loan_face_value => 2000, :loan_term => 6, :annual_rate => 10, :lender_name => "test bank 2", :user_id => user.id)