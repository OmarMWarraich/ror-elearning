require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = categories(:one)
    @admin = users(:one)
    @admin.update!(role: :admin)
    @student = users(:two)
  end

  test "should get index" do
    get categories_url
    assert_response :success
  end

  test "should show category" do
    get category_url(@category)
    assert_response :success
  end

  test "should redirect new when not admin" do
    sign_in @student
    get new_category_url
    assert_redirected_to root_url
  end

  test "should get new when admin" do
    sign_in @admin
    get new_category_url
    assert_response :success
  end

  test "should create category when admin" do
    sign_in @admin
    assert_difference("Category.count") do
      post categories_url, params: { category: { name: "New Category", description: "Desc", position: 1 } }
    end
    assert_redirected_to category_url(Category.last)
  end

  test "should update category when admin" do
    sign_in @admin
    patch category_url(@category), params: { category: { name: "Updated" } }
    assert_redirected_to category_url(@category)
  end

  test "should destroy category when admin" do
    sign_in @admin
    assert_difference("Category.count", -1) do
      delete category_url(@category)
    end
    assert_redirected_to categories_url
  end
end
