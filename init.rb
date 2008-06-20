require 'helper_me_test'

ActionView::TestCase.send :include, HelperMeTest.TagAssertions
ActionView::TestCase.send :include, HelperMeTest.SelectorAssertions
if defined? Hpricot
  ActionView::TestCase.send :include, HelperMeTest.HpricotAssertions
end

