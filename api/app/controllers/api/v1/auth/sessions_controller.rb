# Sign-in, sign-out and "who am I" for the HR Manager.
# Token issuing and revocation are handled by devise-jwt middleware on the
# configured paths; this controller only authenticates and renders the user.
module Api
  module V1
    module Auth
      class SessionsController < ApplicationController
        skip_before_action :authenticate_user!, only: :create
        # Devise only checks email/password when a controller opts in.
        before_action :allow_params_authentication!, only: :create

        # POST /api/v1/auth/sign_in — token is returned in the Authorization header.
        def create
          user = warden.authenticate!(scope: :user, store: false)
          render json: { user: user_json(user) }, status: :ok
        end

        # GET /api/v1/auth/me
        def show
          render json: { user: user_json(current_user) }, status: :ok
        end

        # DELETE /api/v1/auth/sign_out — the token is revoked by devise-jwt.
        def destroy
          head :no_content
        end

        private

        def user_json(user)
          user.slice(:id, :name, :email)
        end
      end
    end
  end
end
