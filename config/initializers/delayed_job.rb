Delayed::Worker.sleep_delay = 60
Delayed::Worker.delay_jobs = !Rails.env.test?
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 3.days
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
#Delayed::Job.destroy_failed_jobs = false
