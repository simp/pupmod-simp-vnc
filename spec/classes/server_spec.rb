require 'spec_helper'

describe 'vnc::server' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to create_class('vnc::server') }

      it { is_expected.to contain_class('xinetd') }
      it { is_expected.to contain_class('gdm') }

      it do
        is_expected.to create_vnc__server__create('vnc_standard').with({
                                                                         'port' => 5901,
          'geometry'  => '1024x768',
          'depth'     => 16
                                                                       })
      end
      it do
        is_expected.to create_vnc__server__create('vnc_lowres').with({
                                                                       'port' => 5902,
          'geometry'  => '800x600',
          'depth'     => 16
                                                                     })
      end
      it do
        is_expected.to create_vnc__server__create('vnc_highres').with({
                                                                        'port' => 5903,
          'geometry'  => '1280x1024',
          'depth'     => 16
                                                                      })
      end

      it { is_expected.to contain_package('tigervnc-server') }
    end
  end
end
