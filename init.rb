require 'redmine_legacy_link/application_helper_patch'

Redmine::Plugin.register :redmine_legacy_link do
  name 'Redmine Legacy Link'
  author 'Shinji Tamura'
  author_url 'https://twitter.com/crosspointst'
  description 'A plugin for Redmine that change old link style in Wiki'
  version '0.0.1'
  requires_redmine version_or_higher: '3.4.3'
  url 'https://github.com/crosspoints/redmine_legacy_link'

  settings partial: 'settings/redmine_legacy_link',
           default: {
             'enable' => 'false',
             'only_link_name' => 'false'
           }

end
