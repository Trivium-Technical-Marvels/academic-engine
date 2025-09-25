module Academic
  module Engine
    class ApplicationController < ActionController::Base
      include ControllerHelpers
      include Pagy::Backend

      before_action :authorize_dean_registrar

      private

      def authorize_dean_registrar
        return render_unauthorized if current_user.nil?

        http_method = request.method_symbol
        case http_method
        when :get
          render_forbidden unless current_user[:types].in?(['Sims::Common::Registrar', 'Sims::Common::Dean'])
        when :post, :put, :patch, :delete
          render_forbidden unless current_user[:types] == 'Sims::Common::Registrar'
        else
          render_forbidden
        end
      end

      def render_unauthorized
        render json: {
          payload: { message: 'Authentication required' },
          status: :unauthorized,
          meta: { pagination: {} }, }, status: :unauthorized
      end

      def render_forbidden
        render json: {
          payload: { message: 'You are not authorized to perform this action' },
          status: :forbidden,
          meta: { pagination: {} }, }, status: :forbidden
      end
    end
  end
end
