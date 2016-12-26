#\ -s puma -E production

$LOAD_PATH << File.join(__dir__, 'app', 'src')

require File.join(__dir__, 'app', 'app.rb')
require 'example_mapper/middlewares/backend.rb'

use Rack::ShowExceptions
use ExampleMapper::Middlewares::Backend

run ExampleMapper::App
