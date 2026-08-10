require "application_system_test_case"

class CategoriesTest < ApplicationSystemTestCase
  setup do
    @category = categories(:one)
    @admin = users(:one)
    @admin.update!(role: :admin)
  end

  test "visiting categories index" do
    visit categories_url
    assert_selector "h1", text: "Categories"
    assert_text @category.name
  end

  test "admin creates a category" do
    sign_in @admin
    visit categories_url
    click_on "New category"
    fill_in "Name", with: "System Test Category"
    fill_in "Position", with: "2"
    click_on "Create Category"
    assert_text "Category was successfully created."
  end
end
