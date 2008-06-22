require File.dirname(__FILE__) + '/generator_test_init'

class HelperGeneratorTest < GeneratorTestCase
  def setup
    super
    cp_r File.join(PLUGIN_ROOT, 'generators/helper'),  File.join(RAILS_ROOT, 'vendor/generators')
  end
  
  context 'using generator with no params' do
    setup do
      # run_generator('helper', %w(Tags))
    end
  end
  
end
