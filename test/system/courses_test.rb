require "application_system_test_case"

class CoursesTest < ApplicationSystemTestCase
  setup do
    @published_course = courses(:one)
    @draft_course = courses(:two)
    @instructor = users(:one)
    @student = users(:two)
  end

  test "visiting the courses index" do
    visit courses_url
    assert_selector "h1", text: "Courses"
    assert_text @published_course.title
  end

  test "viewing a published course" do
    visit course_url(@published_course)
    assert_selector "h1", text: @published_course.title
    assert_link "Back to courses"
  end

  test "searching for a course" do
    visit courses_url
    fill_in "q", with: "Ruby"
    click_on "search-button"
    assert_text "Introduction to Ruby"
  end

  test "creating a course as an instructor" do
    sign_in @instructor
    visit new_course_url
    assert_selector "h1", text: "New course"
    fill_in "Title", with: "System Test Course"
    find(:css, "#course_description", visible: false).set("A course created by system tests.")
    fill_in "Price (cents)", with: "1000"
    fill_in "Duration in minutes", with: "60"
    select "Published", from: "Status"
    click_on "Create Course"
    assert_text "Course was successfully created."
    assert_text "System Test Course"
  end

  test "updating a course as an instructor" do
    sign_in @instructor
    visit edit_course_url(@published_course)
    fill_in "Title", with: "Updated Course Title"
    click_on "Update Course"
    assert_text "Course was successfully updated."
    assert_text "Updated Course Title"
  end

  test "guests cannot create courses" do
    visit new_course_url
    assert_current_path new_user_session_path
  end
end
