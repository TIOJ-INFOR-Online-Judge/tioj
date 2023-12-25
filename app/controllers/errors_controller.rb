class ErrorsController < ApplicationController
  def not_found
    respond_to do |format|
      format.html { render status: 404 }
      format.json { render json: {'message': "This page does not exist."} }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render status: 500 }
      format.json { render json: {'message': "An unexpected error has occurred. We have received the error report and will be addressing it promptly."} }
    end
  end
end
