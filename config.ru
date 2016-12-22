#\ -s puma -E production

require File.join(__dir__, 'app', 'app.rb')
require File.join(__dir__, 'lib', 'example_mapper', 'middlewares', 'backend.rb')

use Rack::ShowExceptions
use ExampleMapper::Middlewares::Backend

run ExampleMapper::App
