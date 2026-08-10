class CategoriesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_category, only: %i[show edit update destroy]
  before_action :authorize_category, only: %i[index new create]

  def index
    @categories = Category.ordered
  end

  def show
    authorize! :read, @category
    @courses = @category.courses.accessible_by(current_ability).published
  end

  def new
    @category = Category.new
    authorize! :create, @category
  end

  def create
    @category = Category.new(category_params)
    authorize! :create, @category

    if @category.save
      redirect_to @category, notice: "Category was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize! :update, @category
  end

  def update
    authorize! :update, @category

    if @category.update(category_params)
      redirect_to @category, notice: "Category was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize! :destroy, @category
    @category.destroy!
    redirect_to categories_path, notice: "Category was successfully destroyed.", status: :see_other
  end

  private

  def set_category
    @category = Category.find(params.expect(:id))
  end

  def authorize_category
    authorize! params[:action].to_sym, Category
  end

  def category_params
    params.expect(category: %i[name description position])
  end
end
