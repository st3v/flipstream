class AddCountryIdToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :country_id, :integer

  end
end
