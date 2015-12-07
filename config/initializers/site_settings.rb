CalendarDateSelect.format = :euro_24hr

module SiteSettings
  site_settings = YAML::load(File.open(File.join(RAILS_ROOT, 'config', 'site_settings.yml')))
  SITE_LAYOUT = 'layout_' + site_settings['layout'].to_s
  DYNAMIC_MODULES = site_settings['dynamic_modules']
end
