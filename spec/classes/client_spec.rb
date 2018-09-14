require 'spec_helper'

describe 'vnc::client' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should compile.with_all_deps }
      it { should create_class('vnc::client') }
      it { should contain_package('tigervnc') }
    end
  end
end
