# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    alias_action :create, :read, :update, :destroy, to: :crud

    # Guests can read published content
    can :read, Course, status: :published
    can :read, Category
    can :read, Lesson, status: :published
    can :read, Review
    can :search, Course

    return unless user.persisted?

    # Students can enroll and complete lessons
    can :read, Course
    can :enroll, Course
    can :read, Lesson, course: { status: :published }
    can :read, Lesson, course: { enrollments: { user_id: user.id } }
    can :create, Enrollment, user_id: user.id
    can :read, Enrollment, user_id: user.id
    can :destroy, Enrollment, user_id: user.id
    can :create, LessonCompletion, user_id: user.id
    can :create, Review, user_id: user.id
    can :update, Review, user_id: user.id
    can :destroy, Review, user_id: user.id

    if user.instructor? || user.admin?
      # Instructors can manage their own courses and nested lessons
      can :crud, Course, instructor_id: user.id
      can :manage, Lesson, course: { instructor_id: user.id }
      can :read, Enrollment, course: { instructor_id: user.id }
      can :read, LessonCompletion, enrollment: { course: { instructor_id: user.id } }
    end

    return unless user.admin?

    # Admins can do everything
    can :manage, :all
  end
end
