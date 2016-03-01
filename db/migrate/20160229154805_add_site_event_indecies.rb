class AddSiteEventIndecies < ActiveRecord::Migration
  def change
    add_index :site_events, :event

    # jsonb index
    add_index :site_events, :payload, :using => :gin
  end
end
