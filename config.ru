#\ -p 9292 -s puma -E production

require File.join(__dir__, 'lib', 'example_mapper', 'app.rb')

run ExampleMapper::App
