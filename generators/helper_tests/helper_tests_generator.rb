class HelperTestsGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      Dir.glob(File.expand_path(File.join(RAILS_ROOT, 'app', 'helpers/**/*_helper.rb'))) do |helper_file|
        
        helper_file_name = File.base_name(helepr_file, '.rb')
        helper_class_name = helper_file_name.camelcase
        
        helper_path = File.dirname(helper_file).
        helper_relative_path = helper_path.gsub(/^#{Regexp.escape(File.expand_path(File.join(RAILS_ROOT, 'app', 'helpers')))}/, '')
        module_names = helper_relative_path.split('/')
        module_names.collect! {|mod| mod.camelcase }
        helper_full_name = module_names.join('::') + '::' + helper_class_name
        
        helper_methods = helper_full_name.constantize.public_instance_methods
        
        m.class_collisions "#{helper_full_name}Test"
        
        m.directory File.join('test/helpers', helper_relative_path)
        
        m.template 'helper_test.rb', 
                    File.join('test/helpers', 
                              helper_relative_path, 
                              "#{helper_file_name}_test.rb"), 
                    :assigns => { :helper_full_name => helper_full_name, 
                                  :helper_methods => helper_methods }
      end
    end
  end
end
