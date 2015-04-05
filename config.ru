# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

# app = self
# map '/foo' do
#   use LicenseChecker
#   run lambda { |env| app.call(env) }
# end
# run Rails.application

# run Rack::URLMap.new '/' => Rails.application, '/foo' => LicenseChecker.new(self)

app = self
Routes = ::Rack::Mount::RouteSet.new do |set|
  set.add_route LicenseChecker.new(app), request_method: 'POST', path_info: '/foo'
  set.add_route Rails.application, path_info: %r{^/}
end

run Routes