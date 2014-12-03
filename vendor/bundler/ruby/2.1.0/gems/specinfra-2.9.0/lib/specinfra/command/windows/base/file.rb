class Specinfra::Command::Windows::Base::File < Specinfra::Command::Windows::Base
  class << self
    def check_is_file(file)
      cmd = item_has_attribute file, 'Archive'
      Backend::PowerShell::Command.new do
        exec cmd
      end
    end

    def check_is_directory(dir)
      cmd = item_has_attribute dir, 'Directory'
      Backend::PowerShell::Command.new do
        exec cmd
      end
    end

    def check_is_hidden(file)
      cmd = item_has_attribute file, 'Hidden'
      Backend::PowerShell::Command.new do
        exec cmd
      end
    end

    def check_is_readonly(file)
      cmd = item_has_attribute file, 'ReadOnly'
      Backend::PowerShell::Command.new do
        exec cmd
      end
    end

    def check_is_system(file)
      cmd = item_has_attribute file, 'System'
      Backend::PowerShell::Command.new do
        exec cmd
      end
    end
  
    def get_content(file)
      %Q![Io.File]::ReadAllText("#{file}")!
    end
  
    def check_is_accessible_by_user(file, user, access)
      case access
      when 'r'
        check_is_readable(file, user)
      when 'w'
        check_is_writable(file, user)
      when 'x'
        check_is_executable(file, user)
      end
    end

    def check_is_readable(file, by_whom)
      Backend::PowerShell::Command.new do
        using 'check_file_access_rules.ps1'
        exec "CheckFileAccessRules -path '#{file}' -identity '#{get_identity by_whom}' -rules @('FullControl', 'Modify', 'ReadAndExecute', 'Read', 'ListDirectory')"
      end
    end

    def check_is_writable(file, by_whom)
      Backend::PowerShell::Command.new do
        using 'check_file_access_rules.ps1'
        exec "CheckFileAccessRules -path '#{file}' -identity '#{get_identity by_whom}' -rules @('FullControl', 'Modify', 'Write')"
      end
    end

    def check_is_executable(file, by_whom)
      Backend::PowerShell::Command.new do
        using 'check_file_access_rules.ps1'
        exec "CheckFileAccessRules -path '#{file}' -identity '#{get_identity by_whom}' -rules @('FullControl', 'Modify', 'ReadAndExecute', 'ExecuteFile')"
      end
    end

    def check_contains(file, pattern)
      Backend::PowerShell::Command.new do
        exec %Q![[Io.File]::ReadAllText("#{file}") -match '#{convert_regexp(pattern)}'!
      end
    end

    def check_contains_within file, pattern, from=nil, to=nil
      from ||= '^'
      to ||= '$'
      Backend::PowerShell::Command.new do
        using 'crop_text.ps1'
        exec %Q!(CropText -text ([Io.File]::ReadAllText("#{file}")) -fromPattern '#{convert_regexp(from)}' -toPattern '#{convert_regexp(to)}') -match '#{pattern}'!
      end
    end

    def check_has_version(name,version)
      cmd = "((Get-Command '#{name}').FileVersionInfo.ProductVersion -eq '#{version}') -or ((Get-Command '#{name}').FileVersionInfo.FileVersion -eq '#{version}')"
      Backend::PowerShell::Command.new { exec cmd }
    end

    private
    def item_has_attribute item, attribute
      %Q!((Get-Item -Path "#{item}" -Force).attributes.ToString() -Split ', ') -contains '#{attribute}'!
    end
  end
end
