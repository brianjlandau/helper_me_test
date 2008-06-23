require 'test_helper'

class <%= helper_full_name %>Test < ActionView::TestCase
<% for hmethod in helper_methods %>
  def test_<%= hmethod %>
    flunk
  end
<% end %>
end
