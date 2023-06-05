class ContestRegistrationsController < InheritedResources::Base
  actions :index, :create, :new, :destroy
  before_action :authenticate_admin!

  def create
  end

 private

end
