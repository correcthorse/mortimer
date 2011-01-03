task :setup do
  $setup_disabled = true
  Rake::Task["environment"].invoke
  env = Rails.env || "DEVELOPMENT" 
  100.times { puts }
  puts "*****mortimer setup for #{env.upcase} environment:*****\n"
  AppSetup.go
end
