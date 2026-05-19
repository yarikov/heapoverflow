# Heap Overflow

Heap Overflow is a web application built with Rails, Turbo, and Stimulus that aims to be a clone of Stack Overflow.

## Table of Contents

- [Description](#description)
- [Installation](#installation)
- [Usage](#usage)
- [Viewing Emails](#viewing-emails)
- [Testing](#testing)
- [License](#license)

## Description

Heap Overflow is a web application that allows users to ask and answer questions on various topics. The app is designed to be similar to Stack Overflow in terms of functionality and design. I created this project as a way to practice my Rails skills and to build something that I would personally find useful.

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

### Running the Application

Start the full web stack (Rails server + asset watchers):

```bash
dip up
```

Then open your browser at [http://localhost:3000](http://localhost:3000).

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

## Usage

1. Start the application: `dip up`
2. Open your web browser and navigate to `http://localhost:3000`
3. Sign up for an account or log in if you already have one
4. Ask or answer questions on the homepage or browse questions by tag

## Viewing Emails

In a development environment, you can view email messages using mailcatcher. To do this, follow these steps:

1. Open your web browser and navigate to `http://localhost:1080`
2. Send an email from the Heap Overflow application (e.g., create a new account or reset your password)
3. Check the mailcatcher web interface to view the email message

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
