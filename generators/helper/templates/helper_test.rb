require 'test_helper'

class <%= helper_name %>HelperTest < ActionView::TestCase

<% for hmethod in helper_methods -%>
  def test_<%= hmethod %>
    flunk
  end
<% end -%>

end
