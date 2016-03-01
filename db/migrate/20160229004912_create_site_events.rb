class CreateSiteEvents < ActiveRecord::Migration
  def change
    create_table :site_events do |t|
      t.references :user, index: true, foreign_key: true
      t.references :site, index: true, foreign_key: true
      t.integer    :event
      t.jsonb      :payload, default: {}

      t.timestamps null: false
    end
  end
end
