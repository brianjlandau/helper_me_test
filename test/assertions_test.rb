ENV["RAILS_ENV"] = "test"
PLUGIN_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'test/unit'
require 'rubygems'
require 'shoulda'
require 'spect'
require 'active_support'
require 'active_support/test_case'
require File.join(PLUGIN_ROOT, 'lib/helper_me_test.rb')

class TagAssertionsTest < ActiveSupport::TestCase
  include HelperMeTest::Assertions::TagAssertions
  
  
end


class HpricotAssertionsTest < ActiveSupport::TestCase
  include HelperMeTest::Assertions::HpricotAssertions
  
  
end


class SelectorAssertionsTest < ActiveSupport::TestCase
  include HelperMeTest::Assertions::HpricotAssertions
  
  
end
