class CreateAttachments < ActiveRecord::Migration[4.2]
  def change
    create_table :attachments do |t|
      t.integer :article_id
      t.string :path
      
      t.timestamps
    end
  end
end
