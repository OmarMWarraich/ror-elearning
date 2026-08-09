class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :description, null: false
      t.integer :status, null: false, default: 0
      t.references :instructor, null: false, foreign_key: { to_table: :users }
      t.references :category, foreign_key: true
      t.integer :price_cents, null: false, default: 0
      t.integer :duration_in_minutes
      t.datetime :published_at

      t.timestamps
    end
    add_index :courses, :title, unique: true
    add_index :courses, :slug, unique: true
    add_index :courses, :status
  end
end
