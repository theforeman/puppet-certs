# this regex rejects any path component that is a / or a NUL
type Certs::Relativeunixpath = Pattern[/^(\.{2}|~)?\/([^\/\0]+?\/*?)+?$/]