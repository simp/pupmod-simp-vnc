require 'spec_helper'

describe 'vnc::server' do

  let(:facts) {{
    :operatingsystem => 'RedHat',
    :lsbmajdistrelease => '6'
  }}

  it { should create_class('vnc::server') }
  it { should compile.with_all_deps }

  it { should contain_class('common') }
  it { should contain_class('xinetd') }
  it { should contain_class('xwindows') }

  it do
    should create_vnc__server__create('vnc_standard').with({
      'port'      => '5901',
      'geometry'  => '1024x768',
      'depth'     => '16'
    })
  end
  it do
    should create_vnc__server__create('vnc_lowres').with({
      'port'      => '5902',
      'geometry'  => '800x600',
      'depth'     => '16'
    })
  end
  it do
    should create_vnc__server__create('vnc_highres').with({
      'port'      => '5903',
      'geometry'  => '1280x1024',
      'depth'     => '16'
    })
  end

  it { should contain_package('tigervnc-server') }
  it { should create_xwindows__gdm__set('enable_xdmcp') }

end
