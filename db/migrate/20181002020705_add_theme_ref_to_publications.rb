class AddThemeRefToPublications < ActiveRecord::Migration[5.2]
  def change
    add_reference :publications, :theme, foreign_key: true
  end
end
