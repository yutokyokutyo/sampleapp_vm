class Specinfra::Helper::DetectOs::Darwin < Specinfra::Helper::DetectOs
  def self.detect
    if run_command('uname -s').stdout =~ /Darwin/i
      { :family => 'darwin', :release => nil }
    end
  end
end
