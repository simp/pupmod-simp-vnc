require 'spec_helper'

describe 'vnc::server' do
  context  'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) do
        facts
      end

      context "on #{os}" do
        it { should create_class('vnc::server') }
        it { should compile.with_all_deps }

        it { should contain_class('simplib') }
        it { should contain_class('xinetd') }
        it { should contain_class('gdm') }

        it do
          should create_vnc__server__create('vnc_standard').with({
            'port'      => 5901,
            'geometry'  => '1024x768',
            'depth'     => 16
          })
        end
        it do
          should create_vnc__server__create('vnc_lowres').with({
            'port'      => 5902,
            'geometry'  => '800x600',
            'depth'     => 16
          })
        end
        it do
          should create_vnc__server__create('vnc_highres').with({
            'port'      => 5903,
            'geometry'  => '1280x1024',
            'depth'     => 16
          })
        end

        it { should contain_package('tigervnc-server') }
        it { should create_gdm__set('enable_xdmcp') }

      end
    end
  end
end
