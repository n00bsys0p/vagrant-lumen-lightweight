class core {
  include apache
  include php
  include apache::mod::rewrite
  include apache::mod::actions
  include apache::mod::mime
  include apache::mod::alias
  include apache::mod::dir
  include mysql::server
}
