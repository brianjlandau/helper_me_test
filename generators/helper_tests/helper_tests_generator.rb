class HelperTestsGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      unless @args.empty?
        @args.each do |helper_class|
          helper_path = helper_class.underscore
          create_helper_test(m, helper_class, helper_path)
        end
      else
        Dir.glob(File.join(RAILS_ROOT, 'app', 'helpers/**/*_helper.rb')) do |helper_file|
          helper_full_path = File.expand_path(helper_file).gsub(/\.rb$/, '')
          helper_relative_path = helper_full_path.gsub(/^#{Regexp.escape(File.expand_path(File.join(RAILS_ROOT, 'app', 'helpers')))}\//, '')
          helper_full_name = helper_relative_path.camelcase

          create_helper_test(m, helper_full_name, helper_relative_path)
        end
      end
    end
  end
  
  private
    def create_helper_test(manifest, helper_full_name, helper_path)
      helper_relative_dir = helper_path.gsub(/(\/)?\w+$/, '')
      helper_file_name = helper_path.match(/\w+$/)[0]
      helper_methods = helper_full_name.constantize.public_instance_methods

      manifest.class_collisions "#{helper_full_name}Test"

      manifest.directory File.join('test/helpers', helper_relative_dir)

      manifest.template 'helper_test.rb', 
                  File.join('test/helpers', 
                            helper_relative_dir, 
                            "#{helper_file_name}_test.rb"), 
                  :assigns => { :helper_full_name => helper_full_name, 
                                :helper_methods => helper_methods }
    end
end
