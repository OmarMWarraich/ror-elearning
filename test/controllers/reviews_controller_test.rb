require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:one)
    @student = users(:two)
    @review = reviews(:one)
  end

  test "should get index" do
    get course_reviews_url(@course)
    assert_response :success
  end

  test "should create review when enrolled" do
    sign_in @student
    @course.enrollments.create!(user: @student, price_paid_cents: 0)
    assert_difference("Review.count") do
      post course_reviews_url(@course), params: { review: { rating: 5, comment: "Great!" } }
    end
    assert_redirected_to @course
  end

  test "should update own review" do
    sign_in @review.user
    patch review_url(@review), params: { review: { comment: "Updated" } }
    assert_redirected_to @review.course
  end

  test "should destroy own review" do
    sign_in @review.user
    assert_difference("Review.count", -1) do
      delete review_url(@review)
    end
    assert_redirected_to @review.course
  end
end
