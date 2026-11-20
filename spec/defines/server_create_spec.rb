require 'spec_helper'

describe 'vnc::server::create' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        let(:title) { 'awesome_vnc' }

        let(:params) { { port: 5900, geometry: '1280x1024', depth: 16, screensaver_timeout: 15 } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.not_to contain_class('xinetd') }

        it do
          is_expected.to contain_systemd__unit_file('awesome_vnc.socket')
            .with_enable(true)
            .with_active(true)
            .with_content(%r{^ListenStream=127\.0\.0\.1:5900$})
            .with_content(%r{^Accept=yes$})
            .with_content(%r{^WantedBy=sockets\.target$})
            .that_requires('Systemd::Unit_file[awesome_vnc@.service]')
        end

        it do
          is_expected.to contain_systemd__unit_file('awesome_vnc@.service')
            .with_content(%r{^User=nobody$})
            .with_content(%r{^StandardInput=socket$})
            .with_content(
              %r{^ExecStart=-/usr/bin/Xvnc -inetd -localhost -audit 4 -s 15 -query localhost -NeverShared -once -SecurityTypes None -desktop awesome_vnc -geometry 1280x1024 -depth 16$},
            )
        end
      end
    end
  end
end
