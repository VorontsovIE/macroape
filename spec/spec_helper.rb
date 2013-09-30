$bioinform_folder = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'bioinform', 'lib'))
$LOAD_PATH.unshift $bioinform_folder

require 'rspec'

# comparing hashes with float values
RSpec::Matchers.define :have_nearly_the_same_values do |expected, vicinity|
  match do |actual|
    expected.all?{|key, _| actual.has_key?(key)} && actual.all?{|key, _| expected.has_key?(key)} && expected.all?{|key, value| (actual[key] - value).abs <= vicinity }
  end
end
