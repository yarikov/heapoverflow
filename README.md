# Heap Overflow

[![CI](https://github.com/yarikov/heapoverflow/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/yarikov/heapoverflow/actions/workflows/ci.yml)
[![Ruby](https://img.shields.io/badge/ruby-4.0.4-red?logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/rails-8.1.3-red?logo=ruby-on-rails&logoColor=white)](https://rubyonrails.org/)
[![License](https://img.shields.io/github/license/yarikov/heapoverflow)](/LICENSE)

Heap Overflow is a Stack Overflow-inspired application built with Rails 8, Hotwire, PostgreSQL, and Elasticsearch.

The primary goal of this project is learning and experimentation. I use it to explore new Rails releases, evaluate gems and libraries, and stay up to date with the modern Rails ecosystem.

This project is not intended for commercial use or production deployment.

## Table of Contents

- [Tech Stack](#tech-stack)
- [Installation](#installation)
- [Usage](#usage)
- [Development](#development)
  - [Viewing Emails](#viewing-emails)
  - [Useful Commands](#useful-commands)
- [Testing](#testing)
- [License](#license)


## Tech Stack

| Layer | Technology |
|-------|------------|
| Backend | Ruby on Rails, Turbo, Stimulus |
| Database | PostgreSQL |
| Search | Elasticsearch |
| CSS | Sass, Bootstrap |
| Containerization | Docker, Dip |
| Testing | RSpec |

## Installation

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed and running
- [Dip](https://github.com/bibendi/dip) installed:

  ```bash
  gem install dip
  ```

### Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/yarikov/heapoverflow.git
   ```

2. Navigate to the project directory:

   ```bash
   cd heapoverflow
   ```

3. Provision the development environment (builds Docker image, starts PostgreSQL and Elasticsearch, installs dependencies, and sets up the database):

   ```bash
   dip provision
   ```

## Usage

Start the application:

```bash
dip up
```

Then open your browser at [http://localhost:3000](http://localhost:3000).

Once the app is running:

1. Sign up for an account or log in if you already have one
2. Ask or answer questions on the homepage or browse questions by tag

## Development

### Viewing Emails

In a development environment, you can view email messages using [mailcatcher](https://github.com/sj26/mailcatcher). To do this, follow these steps:

1. Open your web browser and navigate to http://localhost:1080
2. Send an email from the Heap Overflow application (e.g., create a new account or reset your password)
3. Check the [mailcatcher](https://github.com/sj26/mailcatcher) web interface to view the email message

### Useful Commands

```bash
# Rails console
dip rails c

# Run database migrations
dip rails db:migrate

# PostgreSQL console
dip psql

# Run tests
dip rspec

# Run linter
dip rubocop

# Install Ruby gems
dip bundle install

# Install JS packages
dip yarn install

# Stop all containers
dip down
```

## Testing

The project uses RSpec for testing.

```bash
# Run full test suite
dip rspec

# Run a specific spec file or directory
dip rspec spec/models/question_spec.rb
dip rspec spec/system/
```

## License

Heap Overflow is released under the MIT License. See the [LICENSE](LICENSE) file for more information.
