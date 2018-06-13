Puppet::Type.newtype(:gpg) do
  desc 'GPG key'

  ensurable
  # make ensure present default
  define_method(:managed?) { true }
  newparam(:name, :namevar => true)

  newparam(:generate)
  newparam(:regenerate)
  newparam(:regenerate_ca)
  newparam(:deploy)
  newparam(:hostname)
  newparam(:build_dir)
  newparam(:existing_gpg)
  newparam(:gpg_name)
  newparam(:gpg_comment)
  newparam(:gpg_email)
  newparam(:gpg_key_type)
  newparam(:gpg_key_length)
  newparam(:gpg_expire_date)
  newparam(:subkey)
  newparam(:existing_sub)
  newparam(:sub_key_type)
  newparam(:sub_key_length)
  newparam(:sub_expire_date)
  newparam(:deploy_gpg)
  newparam(:deploy_user)
  newparam(:deploy_group)
  newparam(:deploy_pub_file)
end
