# Ror Elearning

A Rails 8 e-learning platform for creating and consuming online courses. Students can browse and enroll in courses, instructors can publish courses with lessons, and admins manage everything. Authentication, authorization, progress tracking, reviews, and rich-text content are all built in.

## Table of contents

- [Tech stack](#tech-stack)
- [Features](#features)
- [Domain overview](#domain-overview)
- [Getting started](#getting-started)
- [Configuration](#configuration)
- [Database](#database)
- [Running tests](#running-tests)
- [Deployment](#deployment)
- [Authorization](#authorization)
- [License](#license)

## Tech stack

- **Ruby**: 4.0.6 (see [.ruby-version](.ruby-version))
- **Rails**: 8.1.3.1
- **Database**: PostgreSQL 14+
- **Asset pipeline**: [Propshaft](https://github.com/rails/propshaft)
- **JavaScript**: ESM via [importmap-rails](https://github.com/rails/importmap-rails), no bundler required
- **Frontend**: [Bootstrap 5.3.8](https://getbootstrap.com/), [Hotwire](https://hotwired.dev/) (Turbo + Stimulus)
- **Rich text**: Action Text with Trix
- **File uploads**: Active Storage
- **Background jobs**: Solid Queue
- **Caching**: Solid Cache
- **Real-time**: Solid Cable
- **Authentication**: [Devise](https://github.com/heartcombo/devise) 5 with database authenticatable, registerable, recoverable, rememberable, validatable, confirmable, lockable, trackable, and timeoutable
- **Authorization**: [CanCanCan](https://github.com/CanCanCommunity/cancancan)
- **Deployment**: Kamal-ready ([config/deploy.yml](config/deploy.yml)) and Dockerized ([Dockerfile](Dockerfile))

## Features

### Authentication & accounts

- Sign up, sign in, and sign out via Devise
- Log in with **email or username**
- Password reset, email confirmation, account locking, and session timeout
- User profile fields: email, username, first name, last name, bio

### Roles

Three built-in roles powered by a `role` enum on `User`:

- **Guest** — not signed in
- **Student** — signed-up user; can enroll, complete lessons, and review courses
- **Instructor** — can create and manage their own courses and lessons, and view enrollments on their courses
- **Admin** — full access to manage all content

### Categories

- Ordered, slugged categories for grouping courses
- Publicly browsable; only instructors and admins can create or edit them

### Courses

- Rich-text descriptions via Action Text
- Metadata: title, slug, status (`draft`, `published`, `archived`), price, duration, instructor, optional category
- Draft and archived courses are hidden from guests and students until published
- Search courses by title
- Average rating computed from reviews

### Lessons

- Ordered lessons within a course
- Rich-text lesson content
- Status lifecycle (`draft`, `published`, `archived`)
- Guests can only see lessons in published courses; enrolled students can access lessons in their courses

### Enrollments

- Students enroll in courses and pay the listed price (recorded as `price_paid_cents`)
- Enrollment status tracking: `active`, `completed`, or `dropped`
- Progress percentage updates automatically as lessons are completed
- Instructors can view enrollments for their own courses

### Lesson completions

- Students mark lessons complete
- Completions are scoped to the user's active enrollment
- Enrollment progress is recalculated after each completion

### Reviews

- Enrolled students can rate (1–5) and review courses
- Students can edit or delete their own reviews
- Reviews are visible to everyone

### Friendly URLs

- Courses, categories, and lessons use URL-safe slugs generated from their titles

### Responsive UI

- Bootstrap 5 styling throughout, with a custom color palette and form controls

## Domain overview

```text
User
├── has_many :instructed_courses (Course, as instructor)
├── has_many :enrollments
├── has_many :enrolled_courses (Course, through enrollments)
├── has_many :lesson_completions
└── has_many :reviews

Category
└── has_many :courses

Course
├── belongs_to :instructor (User)
├── belongs_to :category (optional)
├── has_many :lessons
├── has_many :enrollments
├── has_many :students (User, through enrollments)
├── has_many :reviews
└── has_rich_text :description

Lesson
├── belongs_to :course
├── has_many :lesson_completions
└── has_rich_text :content

Enrollment
├── belongs_to :user
├── belongs_to :course
└── has_many :lesson_completions

LessonCompletion
├── belongs_to :user
├── belongs_to :lesson
└── belongs_to :enrollment

Review
├── belongs_to :user
└── belongs_to :course
```

## Getting started

### Prerequisites

- Ruby 4.0.5 (use [rbenv](https://github.com/rbenv/rbenv) or [asdf](https://asdf-vm.com/))
- PostgreSQL 14+ running locally
- [libvips](https://www.libvips.org/) for Active Storage image variants (optional but recommended; Rails will warn if missing)

### Installation

```bash
# Clone the repository
git clone <repo-url>
cd ror-elearning

# Install Ruby dependencies
bundle install

# Create and migrate the database
bin/rails db:create db:migrate

# Seed sample data (optional)
bin/rails db:seed

# Start the server
bin/rails server
```

Open [http://localhost:3000](http://localhost:3000).

## Configuration

### Database

Database configuration lives in [config/database.yml](config/database.yml). It uses plain values by default:

```yaml
development:
  adapter: postgresql
  database: elearning3_development
  username: postgres
  password: postgrespassword
  host: localhost
  port: 5432
```

To use Rails credentials instead, wrap Ruby expressions in ERB tags:

```yaml
database: <%= Rails.application.credentials.dig(:database, :name) || "elearning3_development" %>
```

Run `bin/rails credentials:edit` to manage credentials.

### Environment variables

No environment variables are strictly required for local development. Optional variables include:

- `RAILS_MAX_THREADS` — defaults to 5 for database max connections
- `ELEARNING3_DATABASE_PASSWORD` — used in production

## Database

### Create and migrate

```bash
bin/rails db:create db:migrate
```

### Reset

```bash
bin/rails db:drop db:create db:migrate db:seed
```

### Key migrations

- `CreateUsers` — accounts with roles
- `AddDeviseToUsers` — encrypted password, reset tokens, remember token, confirmation, tracking, lockable, and timeout columns
- `CreateCategories` — course categories
- `CreateCourses` — courses with slug, status, price, instructor, category
- `CreateLessons` — ordered lessons with slug and status
- `CreateEnrollments` — student enrollments with progress
- `CreateLessonCompletions` — per-lesson completion tracking
- `CreateReviews` — course ratings and comments
- `CreateActiveStorageTables` and `CreateActionTextTables` — file uploads and rich text

## Running tests

```bash
# Create and migrate the test database
bin/rails db:create db:migrate RAILS_ENV=test

# Run all tests
bin/rails test
```

System tests (browser-driven) can be run with:

```bash
bin/rails test:system
```

## Deployment

The app is configured for deployment with [Kamal](https://kamal-deploy.org/):

```bash
kamal setup
```

See [config/deploy.yml](config/deploy.yml) for server, registry, and accessory configuration. The repository also includes a [Dockerfile](Dockerfile) for container-based deployment.

## Authorization

Authorization is handled by [CanCanCan](https://github.com/CanCanCommunity/cancancan) via [app/models/ability.rb](app/models/ability.rb). Access checks use `authorize!` in controllers and `can?`/`cannot?` in views.

Access-denied exceptions are rescued in [app/controllers/application_controller.rb](app/controllers/application_controller.rb) and redirect guests and unauthorized users to the root path with an alert message.

### Permission matrix

| Resource | Guest | Student | Instructor | Admin |
| --- | --- | --- | --- | --- |
| Courses (read published) | ✅ | ✅ | ✅ | ✅ |
| Courses (search) | ✅ | ✅ | ✅ | ✅ |
| Courses (create / manage) | ❌ | ❌ | own only | ✅ |
| Categories | read only | read only | read only | full |
| Lessons in published courses | ✅ | ✅ | ✅ | ✅ |
| Lessons in own courses | — | — | ✅ | ✅ |
| Enrollments | — | own only | read own course enrollments | full |
| Lesson completions | — | own only | — | full |
| Reviews | read only | own only | read only | full |

### Key abilities

- **Guests** can browse published courses, categories, and lessons, search courses, and read reviews.
- **Students** can enroll in courses, drop their enrollments, complete lessons, and create/edit/destroy their own reviews.
- **Instructors** inherit student abilities and can create, update, and destroy their own courses and the lessons within them. They can also view enrollments and completions for their own courses.
- **Admins** can manage everything.

### Checking abilities

In controllers:

```ruby
authorize! :update, @course
```

In views:

```erb
<% if can? :create, Course %>
  <%= link_to "New course", new_course_path %>
<% end %>
```

Load and authorize collections:

```ruby
@courses = Course.accessible_by(current_ability)
```

## License

MIT. See [LICENSE](LICENSE) if present.
