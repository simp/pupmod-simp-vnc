require 'spec_helper'

describe 'Vnc::Geometry' do
  context 'with valid geometry' do
    it { is_expected.to allow_value('100x200') }
  end

  context 'with invalid geometry' do
    it { is_expected.not_to allow_value('100 x 200') }
    it { is_expected.not_to allow_value(' 100x200') }
    it { is_expected.not_to allow_value('100x200 ') }
    it { is_expected.not_to allow_value('100') }
    it { is_expected.not_to allow_value('100X200') }
  end
end
