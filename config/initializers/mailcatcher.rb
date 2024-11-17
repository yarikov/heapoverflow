return unless Rails.env.development?

Rails.application.configure do
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { address: 'mailcatcher', port: 1025 }
end
