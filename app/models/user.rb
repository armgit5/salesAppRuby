class User < ActiveRecord::Base
  
  before_create { generate_token(:auth_token) }
  
  belongs_to :role
  has_secure_password
  attr_accessible :email, :password, :password_confirmation, :sale_id, :role_id
  validates_uniqueness_of :email
  
  def generate_token(column)
   begin
     self[column] = SecureRandom.urlsafe_base64
   end while User.exists?(column => self[column])
  end
end