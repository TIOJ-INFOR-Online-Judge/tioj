class AnnouncementsController < InheritedResources::Base

  private

    def announcement_params
      params.require(:announcement).permit(:title, :body)
    end

end
