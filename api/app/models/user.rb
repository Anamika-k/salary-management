# An HR Manager who can sign in. Authentication is Devise (passwords) plus
# devise-jwt (stateless tokens); the jti column lets sign-out revoke a token.
class User < ApplicationRecord
  include SoftDeletable
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  validates :name, presence: true

  # Soft-deleted users can neither sign in nor use a token issued earlier.
  def active_for_authentication?
    super && !deleted?
  end
end
