# Ror Elearning

A Rails 8 e-learning platform for creating and consuming online courses. Instructors can publish courses with lessons, students can enroll and track progress, and everyone can leave reviews.

## Table of contents

- [Tech stack](#tech-stack)
- [Features](#features)
- [Domain overview](#domain-overview)
- [Getting started](#getting-started)
- [Configuration](#configuration)
- [Database](#database)
- [Running tests](#running-tests)
- [Asset pipeline](#asset-pipeline)
- [Bootstrap](#bootstrap)
- [Importmap](#importmap)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Tech stack

- **Ruby**: 4.0.5 (see [.ruby-version](.ruby-version))
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
- **Deployment**: Kamal-ready ([config/deploy.yml](config/deploy.yml)) and Dockerized ([Dockerfile](Dockerfile))

## Features

- **User roles**: students, instructors, and admins
- **Categories**: organize courses into ordered categories
- **Courses**: title, slug, rich-text description, status (draft / published / archived), price, duration, instructor, category
- **Lessons**: ordered lessons within a course with rich-text content and status
- **Enrollments**: students can enroll in courses; progress is tracked automatically
- **Lesson completions**: completing a lesson updates enrollment progress
- **Reviews**: students can rate and review courses once enrolled
- **Search**: full-text-ish course search by title
- **Friendly URLs**: slugs for courses, categories, and lessons
- **Bootstrap UI**: responsive styling and components out of the box

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

# Install JavaScript dependencies (none via npm; importmap vendors them)
# Bootstrap and Popper are already vendored in vendor/javascript

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
- `CreateCategories` — course categories
- `CreateCourses` — courses with slug, status, price, instructor, category
- `CreateLessons` — ordered lessons with slug and status
- `CreateEnrollments` — student enrollments with progress
- `CreateLessonCompletions` — per-lesson completion tracking
- `CreateReviews` — course ratings and comments
- `CreateActiveStorageTables` and `CreateActionTextTables` — file uploads and rich text

## Running tests

```bash
# Create the test database
bin/rails db:create RAILS_ENV=test

# Migrate the test database
bin/rails db:migrate RAILS_ENV=test

# Run all tests
bin/rails test
```

System tests (browser-driven) can be run with:

```bash
bin/rails test:system
```

## Asset pipeline

This app uses [Propshaft](https://github.com/rails/propshaft). Assets are served directly without a build step. Stylesheets live in [app/assets/stylesheets/](app/assets/stylesheets/) and JavaScript lives in [app/javascript/](app/javascript/).

Stylesheets are linked directly from [app/views/layouts/application.html.erb](app/views/layouts/application.html.erb):

```erb
<%= stylesheet_link_tag :app, "actiontext", "data-turbo-track": "reload" %>
```

`:app` loads `application.css`; `"actiontext"` loads Action Text's Trix styles.

Precompile assets for production or before running tests that render views:

```bash
bin/rails assets:precompile
```

Clean precompiled assets in development:

```bash
bin/rails assets:clobber
```

## Bootstrap

Bootstrap 5.3.8 is vendored locally in [vendor/javascript/](vendor/javascript/):

- `vendor/javascript/bootstrap.js` — Bootstrap bundle with Popper included
- `vendor/javascript/bootstrap.css` — Bootstrap CSS

It is imported in [app/javascript/application.js](app/javascript/application.js) and included via `@import url("bootstrap.css")` in [app/assets/stylesheets/application.css](app/assets/stylesheets/application.css).

Bootstrap tooltips and popovers are initialized globally on `turbo:load`.

### Updating Bootstrap

```bash
# Download latest files and remove source map comments
curl -L -o vendor/javascript/bootstrap.js https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js
curl -L -o vendor/javascript/bootstrap.css https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css
```

Then remove the trailing `sourceMappingURL` comments to avoid Rails missing-asset warnings.

## Importmap

JavaScript dependencies are managed by [importmap-rails](https://github.com/rails/importmap-rails). The map is defined in [config/importmap.rb](config/importmap.rb).

Pin a new package:

```bash
./bin/importmap pin <package-name>
```

Check for outdated packages:

```bash
./bin/importmap outdated
```

### Why not use JSPM for Bootstrap?

The JSPM ESM build of Bootstrap imports shared helper chunks such as `../_/a0ba12d2.js`. `importmap-rails` only vendors the main entry point, causing 404 errors for those chunks. Using the self-contained `bootstrap.bundle.min.js` from jsDelivr avoids the problem entirely.

## Deployment

The app is configured for deployment with [Kamal](https://kamal-deploy.org/):

```bash
kamal setup
```

See [config/deploy.yml](config/deploy.yml) for server, registry, and accessory configuration. The repository also includes a [Dockerfile](Dockerfile) for container-based deployment.

## Troubleshooting

### `ActiveRecord::ConnectionNotEstablished: invalid integer value ...`

Caused by YAML values like `port: Rails.application.credentials.dig(:database, :port)` without ERB tags. Wrap them in `<%= %>`.

### `LoadError: pg is not part of the bundle`

PostgreSQL is required. The `pg` gem is listed in [Gemfile](Gemfile). Run `bundle install` if it is missing.

### `The asset 'actiontext.css' was not found`

Action Text's CSS is loaded via `stylesheet_link_tag :app, "actiontext"` in the layout. If Propshaft reports it missing after running `bin/rails action_text:install`, restart the Rails server so the new file is picked up from the asset load path.

### `_/a0ba12d2.js` routing errors

This happens when the JSPM ESM build of Bootstrap is used. Switch to the jsDelivr bundle as described in [Bootstrap](#bootstrap).

### Enum argument errors (`wrong number of arguments`)

Rails 8.1 requires the positional enum syntax:

```ruby
enum :status, { draft: 0, published: 1, archived: 2 }
```

## License

MIT. See [LICENSE](LICENSE) if present.
