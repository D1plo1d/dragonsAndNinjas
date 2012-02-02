require "yaml"

hash = {moo: [{"a" => "1", "b" => "2"}, {c: 3, d: 4}]}
puts hash.inspect
puts hash.to_yaml.gsub(" ", "0").inspect

File.open( 'test.yaml', 'w' ) do |out|
  YAML.dump(hash, out)
end

puts YAML.load(File.open("test2.yaml")).inspect

