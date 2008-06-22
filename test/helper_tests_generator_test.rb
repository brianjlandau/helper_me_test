require File.dirname(__FILE__) + '/generator_test_init'

class HelperTestsGeneratorTest < GeneratorTestCase
  def setup
    super
    cp_r File.join(PLUGIN_ROOT, 'generators/helper_tests'),  File.join(RAILS_ROOT, 'vendor/generators')
  end
  
  context 'using generator with no params' do
    setup do
      run_generator('helper_tests', %w())
    end
    
    should 'create helper tests' do
      assert_generated_class 'test/helpers/blog_helper_test', 'ActionView::TestCase'
      assert_generated_class 'test/helpers/sample_helper_test', 'ActionView::TestCase'
    end
    
    should 'create create tests for each method in helper' do
      assert_generated_class 'test/helpers/blog_helper_test', 'ActionView::TestCase' do |file|
        assert_has_method file, :test_post_formater, :test_date_formater
      end
      
      assert_generated_class 'test/helpers/sample_helper_test', 'ActionView::TestCase' do |file|
        assert_has_method file, :test_some_method, :test_another_helper
      end
    end
  end
  
end
