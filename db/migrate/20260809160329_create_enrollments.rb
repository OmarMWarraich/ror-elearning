class CreateEnrollments < ActiveRecord::Migration[8.1]
  def change
    create_table :enrollments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :progress_percentage, null: false, default: 0
      t.datetime :completed_at
      t.datetime :enrolled_at
      t.integer :price_paid_cents, null: false, default: 0

      t.timestamps
    end
    add_index :enrollments, [ :user_id, :course_id ], unique: true
  end
end
