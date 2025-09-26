require 'sidekiq-scheduler'

Sidekiq.configure_server do |config|
  config.on(:startup) do
    schedule_file = Rails.root.join('config', 'sidekiq_schedule.yml')
    Sidekiq.schedule = YAML.load_file(schedule_file) if File.exist?(schedule_file)
    Sidekiq::Scheduler.enabled = true
    Sidekiq::Scheduler.reload_schedule!
    Rails.logger.info "Sidekiq Scheduler loaded with #{Sidekiq.schedule.keys.count} scheduled job(s)"
  end
end

if Rails.env.test?
  require 'sidekiq/testing'
  Sidekiq::Testing.inline!
end