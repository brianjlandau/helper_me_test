Helper Me Test
==============

Providing quick and easy ways to create and write tests for your Rails helpers.


Features
---------

### Assertions / Test Helper Methods

* __Tag Assertions:__
    * `assert_tag_in` and `assert_tag_not_in` mirror the `assert_tag` method built
      into Rails. They work with the same option, only that they need a target
      string as the first parameter.
* __Selector Assertion:__
    * `assert_select_in` works almost identically to `assert_select` does in Rails.
      It allows for a CSS selector to be matched against a HTML string target.
      It also accepts an equality expression and can be nested like `assert_select`.
* __Hpricot Assertion:__
    * `assert_hpricot_in`, and `assert_hpricot_not_in` test that a given CSS or XPath
      expression can be found in an HTML string. See Hpricot documentation for details.

### Generators

* __Helper Test Generator:__
    * Creates helper tests for each helper you currently have, creating one test for
      each public method in the module. If you instead pass it a space separated set
      of helper module names you'll only generate tests for those.
* __Helper Generator:__
    * Creates a helper based on a camelcased or underscored name, and a test file
      for it. It will also accept a list of method names and create methods for
      each of them and a test for each of the methods.


Examples
---------

Example goes here.


### License

Copyright (c) 2008 Brian Landau of Viget Labs, released under the MIT license
