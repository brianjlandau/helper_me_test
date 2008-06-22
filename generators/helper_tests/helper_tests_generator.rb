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
          # get full file path without extension
          helper_full_path = File.expand_path(helper_file).gsub(/\.rb$/, '')
          # get path relative to helpers directory
          helper_relative_path = helper_full_path.gsub(/^#{Regexp.escape(File.join(RAILS_ROOT, 'app', 'helpers'))}\//, '')
          helper_full_name = helper_relative_path.camelcase

          create_helper_test(m, helper_full_name, helper_relative_path)
        end
      end
    end
  end
  
  protected
    def banner
      "Usage: #{$0} #{spec.name} [SampleHelper, Admin::AnotherHelper, ...]"
    end
  
  private
    def create_helper_test(manifest, helper_full_name, helper_path)
      helper_relative_dir = File.dirname(helper_path)
      helper_file_name = File.basename(helper_path)
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
