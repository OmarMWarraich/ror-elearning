class RemoveDescriptionFromCourses < ActiveRecord::Migration[8.1]
  def change
    remove_column :courses, :description, :text
  end
end
