class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.string :code
      t.datetime :expiration_date
      t.integer :type_sub

      t.timestamps
    end
  end
end
