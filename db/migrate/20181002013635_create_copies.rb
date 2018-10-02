class CreateCopies < ActiveRecord::Migration[5.2]
  def change
    create_table :copies do |t|
      t.string :code
      t.integer :place

      t.timestamps
    end
  end
end
