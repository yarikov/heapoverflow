# Heap Overflow

Heap Overflow is a web application built with Rails 7, Turbo, and Stimulus that aims to be a clone of Stack Overflow.

## Table of Contents

- [Description](#description)
- [Installation](#installation)
- [Usage](#usage)
- [Viewing Emails](#viewing-emails)
- [Contributing](#contributing)
- [License](#license)

## Description

Heap Overflow is a web application that allows users to ask and answer questions on various topics. The app is designed to be similar to Stack Overflow in terms of functionality and design. I created this project as a way to practice my Rails skills and to build something that I would personally find useful.

## Installation

1. Clone the repository: `git clone https://github.com/yarikov/heapoverflow.git`
2. Navigate to the project directory: `cd heapoverflow`
3. To install all necessary dependencies run command (docker required): `make setup`

## Usage

1. Start the application: `make run`
2. Open your web browser and navigate to `http://localhost:3000`
3. Sign up for an account or log in if you already have one
4. Ask or answer questions on the homepage or browse questions by tag

## Viewing Emails

In a development environment, you can view email messages using mailcatcher. To do this, follow these steps:

1. Open your web browser and navigate to `http://localhost:1080`
2. Send an email from the Heap Overflow application (e.g., create a new account or reset your password)
3. Check the mailcatcher web interface to view the email message

## Contributing

If you're interested in contributing to Heap Overflow, I welcome your input! Here are a few ways you can get involved:

- Submit bug reports or feature requests by opening an issue on GitHub
- Fork the repository and create a pull request to fix a bug or add a feature
- Help improve the documentation by submitting a pull request to the README file

## License

Heap Overflow is released under the MIT License. See the [LICENSE](LICENSE) file for more information.
