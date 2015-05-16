require 'spec_helper'

describe 'vnc::client' do

  it { should create_class('vnc::client') }
  it { should compile.with_all_deps }
  it { should contain_package('tigervnc') }

end
