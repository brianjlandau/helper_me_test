require 'active_support'
require 'action_controller'
require 'action_view'
require 'action_view/test_case'
require 'rexml/document'
require 'html/document'

begin
  require 'hpricot'
rescue LoadError
end

# HelperMeTest
module HelperMeTest
  
  module Assertions
    
    # Pair of assertions to testing elements in the HTML of a target string.
    module TagAssertions
      
      # Asserts that there is a tag/node/element in the HTML of a target string
      # that meets all of the given conditions. The +conditions+ parameter must
      # be a hash of any of the following keys (all are optional):
      #
      # * <tt>:tag</tt>: the node type must match the corresponding value
      # * <tt>:attributes</tt>: a hash. The node's attributes must match the
      #   corresponding values in the hash.
      # * <tt>:parent</tt>: a hash. The node's parent must match the
      #   corresponding hash.
      # * <tt>:child</tt>: a hash. At least one of the node's immediate children
      #   must meet the criteria described by the hash.
      # * <tt>:ancestor</tt>: a hash. At least one of the node's ancestors must
      #   meet the criteria described by the hash.
      # * <tt>:descendant</tt>: a hash. At least one of the node's descendants
      #   must meet the criteria described by the hash.
      # * <tt>:sibling</tt>: a hash. At least one of the node's siblings must
      #   meet the criteria described by the hash.
      # * <tt>:after</tt>: a hash. The node must be after any sibling meeting
      #   the criteria described by the hash, and at least one sibling must match.
      # * <tt>:before</tt>: a hash. The node must be before any sibling meeting
      #   the criteria described by the hash, and at least one sibling must match.
      # * <tt>:children</tt>: a hash, for counting children of a node. Accepts
      #   the keys:
      #   * <tt>:count</tt>: either a number or a range which must equal (or
      #     include) the number of children that match.
      #   * <tt>:less_than</tt>: the number of matching children must be less
      #     than this number.
      #   * <tt>:greater_than</tt>: the number of matching children must be
      #     greater than this number.
      #   * <tt>:only</tt>: another hash consisting of the keys to use
      #     to match on the children, and only matching children will be
      #     counted.
      # * <tt>:content</tt>: the textual content of the node must match the
      #   given value. This will not match HTML tags in the body of a
      #   tag--only text.
      #
      # Conditions are matched using the following algorithm:
      #
      # * if the condition is a string, it must be a substring of the value.
      # * if the condition is a regexp, it must match the value.
      # * if the condition is a number, the value must match number.to_s.
      # * if the condition is +true+, the value must not be +nil+.
      # * if the condition is +false+ or +nil+, the value must be +nil+.
      #
      # === Examples
      #
      #   # Assert that there is a "span" tag
      #   assert_tag_in "<span>My Tag</span>", :tag => "span"
      #
      #   # Assert that there is a "span" tag with id="x"
      #   assert_tag_in '<span id="x">My Tag</span>', :tag => "span", :attributes => { :id => "x" }
      #
      #   # Assert that there is a "span" tag using the short-hand
      #   assert_tag_in "<span>My Tag</span>", :span
      #
      #   # Assert that there is a "span" inside of a "div"
      #   assert_tag_in "<div><span>My Tag</span></div>", :tag => "span", :parent => { :tag => "div" }
      #
      #   # Assert that there is a "span" with at least one "em" child
      #   assert_tag_in "<span><em>My Tag</em></span>", :tag => "span", :child => { :tag => "em" }
      #
      #   # Assert that there is a "span" containing a (possibly nested)
      #   # "strong" tag.
      #   assert_tag_in helper_string, :tag => "span", :descendant => { :tag => "strong" }
      #
      #   # Assert that there is a "span" containing between 2 and 4 "em" tags
      #   # as immediate children
      #   assert_tag_in helper_string :tag => "span",
      #                               :children => { :count => 2..4, :only => { :tag => "em" } } 
      #
      # <b>Please note</b>: +assert_tag_in+ and +assert_tag_not_in+ only work
      # with well-formed XHTML. They recognize a few tags as implicitly self-closing
      # (like br and hr and such) but will not work correctly with tags
      # that allow optional closing tags (p, li, td). <em>You must explicitly
      # close all of your tags to use these assertions.</em>
      def assert_tag_in(*opts)
        clean_backtrace_view_assertions do
          target = opts.shift
          tag_opts = find_tag_opts(opts)
          assert !find_tag_in(target, tag_opts).nil?, 
                 "#{tag_opts.inspect} was not found in \n#{target.inspect}"
        end
      end
      
      # Identical to +assert_tag_in+, but asserts that a matching tag does _not_
      # exist. (See +assert_tag_in+ for a full discussion of the syntax.)
      def assert_tag_not_in(*opts)
        clean_backtrace_view_assertions do
          target = opts.shift
          tag_opts = find_tag_opts(opts)
          assert find_tag_in(target, tag_opts).nil?, 
                 "#{tag_opts.inspect} was found in \n#{target.inspect}"
        end
      end
      
      
      private
      
        def find_tag_opts(opts)
          if opts.size > 1
            find_opts = opts.last.merge({ :tag => opts.first.to_s })
          else
            find_opts = opts.first.is_a?(Symbol) ? { :tag => opts.first.to_s } : opts.first
          end
          find_opts
        end

        def find_tag_in(target, opts = {})
          target = ::HTML::Document.new(target, false, false)
          target.find(opts)
        end
        
    end
    
    
    if defined? Hpricot
    # Adds the abitlity to do Hpricot search based asserts on generated HTML 
    # for helper tests
    module HpricotAssertions
      ##
      # Does an Hpricot search on a given target. See Hpricot for documentation.
      def assert_xpath_in(target, match)
        target = Hpricot(target)
        assert !target.search(match).empty?, 
               "expected tag, but no tag found matching #{match.inspect} in:\n#{target.inspect}"
      end
    end
    end
    
    
    # Adds the +assert_select+ method for use in Rails helper
    # test cases, which can be used to make assertions on the HTML of a helper 
    # method. You can also call +assert_select+ within another +assert_select+ to
    # make assertions on elements selected by the enclosing assertion.
    #
    # Also see HTML::Selector to learn how to use selectors.
    module SelectorAssertions
      # :call-seq:
      #   assert_select(target, selector, equality?, message?)
      #
      # An assertion that selects elements and makes one or more equality tests.
      #
      # The first parameter specifies the target HTML to which the selector should match
      #
      # ==== Example
      #   assert_select "ol>li" do |elements|
      #     elements.each do |element|
      #       assert_select element, "li"
      #     end
      #   end
      #
      # Or for short:
      #   assert_select "ol>li" do
      #     assert_select "li"
      #   end
      #
      # The selector may be a CSS selector expression (String), an expression
      # with substitution values, or an HTML::Selector object.
      #
      # === Equality Tests
      #
      # The equality test may be one of the following:
      # * <tt>true</tt> - Assertion is true if at least one element selected.
      # * <tt>false</tt> - Assertion is true if no element selected.
      # * <tt>String/Regexp</tt> - Assertion is true if the text value of at least
      #   one element matches the string or regular expression.
      # * <tt>Integer</tt> - Assertion is true if exactly that number of
      #   elements are selected.
      # * <tt>Range</tt> - Assertion is true if the number of selected
      #   elements fit the range.
      # If no equality test specified, the assertion is true if at least one
      # element selected.
      #
      # To perform more than one equality tests, use a hash with the following keys:
      # * <tt>:text</tt> - Narrow the selection to elements that have this text
      #   value (string or regexp).
      # * <tt>:html</tt> - Narrow the selection to elements that have this HTML
      #   content (string or regexp).
      # * <tt>:count</tt> - Assertion is true if the number of selected elements
      #   is equal to this value.
      # * <tt>:minimum</tt> - Assertion is true if the number of selected
      #   elements is at least this value.
      # * <tt>:maximum</tt> - Assertion is true if the number of selected
      #   elements is at most this value.
      #
      # If the method is called with a block, once all equality tests are
      # evaluated the block is called with an array of all matched elements.
      #
      # ==== Examples
      #
      #   # At least one form element
      #   assert_select "form"
      #
      #   # Form element includes four input fields
      #   assert_select "form input", 4
      #
      #   # Page title is "Welcome"
      #   assert_select "title", "Welcome"
      #
      #   # Page title is "Welcome" and there is only one title element
      #   assert_select "title", {:count=>1, :text=>"Welcome"},
      #       "Wrong title or more than one title element"
      #
      #   # Page contains no forms
      #   assert_select "form", false, "This page must contain no forms"
      #
      #   # Test the content and style
      #   assert_select "body div.header ul.menu"
      #
      #   # Use substitution values
      #   assert_select "ol>li#?", /item-\d+/
      #
      #   # All input fields in the form have a name
      #   assert_select "form input" do
      #     assert_select "[name=?]", /.+/  # Not empty
      #   end
      def assert_select_in(*args, &block)
        if @selected
          root = HTML::Node.new(nil)
          root.children.concat @selected
        else
          # Start with mandatory target.
          target = args.shift
          root = HTML::Node.new(target)
        end
        
        # Then get mandatory selector.
        arg = args.shift
        
        # string and we pass all remaining arguments.
        # Array and we pass the argument. Also accepts selector itself.
        case arg
          when String
            selector = HTML::Selector.new(arg, args)
          when Array
            selector = HTML::Selector.new(*arg)
          when HTML::Selector
            selector = arg
          else raise ArgumentError, "Expecting a selector as the first argument"
        end
        
        # Next argument is used for equality tests.
        equals = {}
        case arg = args.shift
          when Hash
            equals = arg
          when String, Regexp
            equals[:text] = arg
          when Integer
            equals[:count] = arg
          when Range
            equals[:minimum] = arg.begin
            equals[:maximum] = arg.end
          when FalseClass
            equals[:count] = 0
          when NilClass, TrueClass
            equals[:minimum] = 1
          else raise ArgumentError, "I don't understand what you're trying to match"
        end

        # By default we're looking for at least one match.
        if equals[:count]
          equals[:minimum] = equals[:maximum] = equals[:count]
        else
          equals[:minimum] = 1 unless equals[:minimum]
        end

        # Last argument is the message we use if the assertion fails.
        message = args.shift
        #- message = "No match made with selector #{selector.inspect}" unless message
        if args.shift
          raise ArgumentError, "Not expecting that last argument, you either have too many arguments, or they're the wrong type"
        end

        matches = selector.select(root)
        # If text/html, narrow down to those elements that match it.
        content_mismatch = nil
        if match_with = equals[:text]
          matches.delete_if do |match|
            text = ""
            text.force_encoding(match_with.encoding) if text.respond_to?(:force_encoding)
            stack = match.children.reverse
            while node = stack.pop
              if node.tag?
                stack.concat node.children.reverse
              else
                content = node.content
                content.force_encoding(match_with.encoding) if content.respond_to?(:force_encoding)
                text << content
              end
            end
            text.strip! unless NO_STRIP.include?(match.name)
            unless match_with.is_a?(Regexp) ? (text =~ match_with) : (text == match_with.to_s)
              content_mismatch ||= build_message(message, "<?> expected but was\n<?>.", match_with, text)
              true
            end
          end
        elsif match_with = equals[:html]
          matches.delete_if do |match|
            html = match.children.map(&:to_s).join
            html.strip! unless NO_STRIP.include?(match.name)
            unless match_with.is_a?(Regexp) ? (html =~ match_with) : (html == match_with.to_s)
              content_mismatch ||= build_message(message, "<?> expected but was\n<?>.", match_with, html)
              true
            end
          end
        end
        # Expecting foo found bar element only if found zero, not if
        # found one but expecting two.
        message ||= content_mismatch if matches.empty?
        # Test minimum/maximum occurrence.
        min, max = equals[:minimum], equals[:maximum]
        message = message || %(Expected #{count_description(min, max)} matching "#{selector.to_s}", found #{matches.size}.)
        assert matches.size >= min, message if min
        assert matches.size <= max, message if max
        
        # If a block is given call that block. Set @selected to allow
        # nested assert_select, which can be nested several levels deep.
        if block_given? && !matches.empty?
          begin
            in_scope, @selected = @selected, matches
            yield matches
          ensure
            @selected = in_scope
          end
        end

        # Returns all matches elements.
        matches
      end
      
      private
        def count_description(min, max) #:nodoc:
          pluralize = lambda {|word, quantity| word << (quantity == 1 ? '' : 's')}

          if min && max && (max != min)
            "between #{min} and #{max} elements"
          elsif min && !(min == 1 && max == 1)
            "at least #{min} #{pluralize['element', min]}"
          elsif max
            "at most #{max} #{pluralize['element', max]}"
          end
        end
    end
    
  end
end
