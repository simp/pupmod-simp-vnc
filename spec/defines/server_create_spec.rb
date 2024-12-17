require 'spec_helper'

describe 'vnc::server::create' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        let(:title) { 'awesome_vnc' }

        let(:params) { { port: 5900, geometry: '1280x1024', depth: 16, screensaver_timeout: 15 } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('xinetd') }

        it do
          is_expected.to contain_xinetd__service('awesome_vnc').with({
                                                                       'banner' => '/dev/null',
            'flags'          => ['REUSE', 'IPv4'],
            'protocol'       => 'tcp',
            'socket_type'    => 'stream',
            'x_wait'         => 'no',
            'x_type'         => 'UNLISTED',
            'log_on_success' => ['HOST', 'PID', 'DURATION'],
            'user'           => 'nobody',
            'server'         => '/usr/bin/Xvnc',
            'server_args'    => '-inetd -localhost -audit 4 -s 15 -query localhost -NeverShared -once -SecurityTypes None -desktop awesome_vnc -geometry 1280x1024 -depth 16',
            'disable'        => 'no',
            'trusted_nets'   => ['127.0.0.1'],
            'port'           => 5900
                                                                     })
        end
      end
    end
  end
end
