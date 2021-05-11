describe 'certs::pulp_client', order: :defined do
  context 'installation' do
    let(:pp) do
      <<~PUPPET
      class { 'certs::pulp_client':
        ensure => present,
      }
      PUPPET
    end

    it_behaves_like 'a idempotent resource'
  end

  context 'removal' do
    let(:pp) do
      <<~PUPPET
      class { 'certs::pulp_client':
        ensure => absent,
      }
      PUPPET
    end

    it_behaves_like 'a idempotent resource'
  end
end
