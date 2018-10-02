class CreateSubscriptionHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :subscription_histories do |t|
      t.integer :canceled_times

      t.timestamps
    end
  end
end
