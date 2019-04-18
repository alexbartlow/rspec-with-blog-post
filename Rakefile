require 'erb'

file 'output.md' => 'input.md' do
  File.write('output.md', ERB.new(File.read('input.md')).result(binding))
end
