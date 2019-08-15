class HostWorker
  include Sidekiq::Worker
  def perform
    loop do
      puts Time.now
      sleep 10
      break if cancelled?
    end
  end

  def cancelled?
    Sidekiq.redis {|c| c.exists("cancelled-#{jid}") }
  end

  def cancel!
    Sidekiq.redis {|c| c.setex("cancelled-#{jid}", 86400, 1) }
  end
end