require 'spec_helper'

describe 'vnc::client' do
  context  'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) do
        facts
      end

      context "on #{os}" do
        it { should create_class('vnc::client') }
        it { should compile.with_all_deps }
        it { should contain_package('tigervnc') }
      end
    end
  end
end
