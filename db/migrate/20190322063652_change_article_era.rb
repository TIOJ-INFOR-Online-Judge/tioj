class ChangeArticleEra < ActiveRecord::Migration[4.2]
  def up
    Article.all.each do |art|
      art.update!(era: art.created_at.year)
    end
  end
end
