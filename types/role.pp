# The all-* values map to presets in generate_archive
# The array values map to actual class names
type Certs::Role = Variant[Enum['all-server', 'all-proxy'], Array[Enum['apache', 'foreman', 'foreman_proxy', 'puppet', 'qpid', 'qpid_client', 'qpid_router'], 1]]
