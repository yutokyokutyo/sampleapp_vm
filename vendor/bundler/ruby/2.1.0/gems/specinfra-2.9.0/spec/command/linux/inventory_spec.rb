require 'spec_helper'

set :os, :family => 'linux'

describe get_command(:get_inventory_memory) do
  it { should eq 'cat /proc/meminfo' }
end
