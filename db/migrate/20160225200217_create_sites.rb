class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.references :user, index: true, foreign_key: true
      t.string     :name, null: false
      t.string     :url
      t.string     :account_id

      t.timestamps null: false
    end
  end
end
