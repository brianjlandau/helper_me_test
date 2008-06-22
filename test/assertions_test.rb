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
  
  def test_assert_tag_in_with_shorthand
    html = '<p id="test">hello world</p>'
    assert_tag_in html, :p
    assert_tag_not_in html, :span
  end
  
  def test_assert_tag_in_with_tag
    html = '<p id="test">hello world</p>'
    assert_tag_in html, :tag => 'p'
    assert_tag_not_in html, :tag => 'span'
  end
  
  def test_assert_tag_in_with_attributes
    html = '<p id="test">hello world</p>'
    assert_tag_in html, :p, :attributes => {:id => 'test'}
    assert_tag_not_in html, :p, :attributes => {:class => 'test'}
  end
  
  def test_assert_tag_in_with_child
    html = '<p><span id="test">hello world</span></p>'
    assert_tag_in html, :p, :child => { :tag => 'span', :attributes => {:id => 'test'} }
    assert_tag_not_in html, :p, :child => {:tag => 'strong'}
  end
  
end


class HpricotAssertionsTest < ActiveSupport::TestCase
  include HelperMeTest::Assertions::HpricotAssertions
  
  def test_assert_hpricot_in
    html = '<p id="test"><span>hello world</span></p>'
    assert_hpricot_in html, 'p[@id="test"]/span'
    assert_hpricot_not_in html, 'div/form'
  end
  
end


class SelectorAssertionsTest < ActiveSupport::TestCase
  include HelperMeTest::Assertions::HpricotAssertions
  
  
end
