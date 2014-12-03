class Specinfra::Helper::DetectOs::Aix < Specinfra::Helper::DetectOs
  def self.detect
    if run_command('uname -s').stdout =~ /AIX/i
      { :family => 'aix', :release => nil }
    end
  end
end
