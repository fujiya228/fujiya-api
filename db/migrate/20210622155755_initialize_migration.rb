class InitializeMigration < ActiveRecord::Migration[6.1]
  def change
    create_table :locations do |t|
      t.string :location_id, null: false # id
      t.float :latitude, null: false # 緯度
      t.float :longitude, null: false # 経度

      t.timestamps
    end

    add_index :locations, [:location_id], unique: true

    create_table :places do |t|
      t.bigint :location_id, null: false
      t.string :place_type, null: false
      t.integer :count, null: false

      t.timestamps
    end

    create_table :scores do |t|
      t.bigint :location_id, null: false
      t.string :score_type, null: false
      t.integer :point, null: false

      t.timestamps
    end
  end
end
