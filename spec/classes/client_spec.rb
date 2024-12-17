require 'spec_helper'

describe 'vnc::client' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to create_class('vnc::client') }
      it { is_expected.to contain_package('tigervnc') }
    end
  end
end
