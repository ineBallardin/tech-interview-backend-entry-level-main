require 'sidekiq-scheduler'

if defined?(Sidekiq)
  Sidekiq.configure_server do |config|
    schedule_file = Rails.root.join('config', 'sidekiq_schedule.yml')
    
    if File.exist?(schedule_file)
      config.on(:startup) do
        schedule = YAML.load_file(schedule_file)
        Sidekiq.schedule = schedule
        Sidekiq::Scheduler.reload_schedule!m
        
        Rails.logger.info "Sidekiq Scheduler loaded with #{schedule.keys.count} scheduled job(s)"
      end
    else
      Rails.logger.warn "Schedule file not found: #{schedule_file}"
    end
  end
end

if Rails.env.test?
  require 'sidekiq/testing'
  Sidekiq::Testing.inline!
end