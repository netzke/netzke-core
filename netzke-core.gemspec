# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{netzke-core}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sergei Kozlov"]
  s.date = %q{2009-05-03}
  s.description = %q{Build ExtJS/Rails widgets with minimum effort}
  s.email = %q{sergei@writelesscode.com}
  s.extra_rdoc_files = ["CHANGELOG", "lib/app/controllers/netzke_controller.rb", "lib/app/models/netzke_layout.rb", "lib/app/models/netzke_preference.rb", "lib/netzke/action_view_ext.rb", "lib/netzke/base.rb", "lib/netzke/base_extras/interface.rb", "lib/netzke/base_extras/js_builder.rb", "lib/netzke/controller_extensions.rb", "lib/netzke/core_ext.rb", "lib/netzke/feedback_ghost.rb", "lib/netzke/routing.rb", "lib/netzke-core.rb", "lib/vendor/facets/hash/recursive_merge.rb", "LICENSE", "README.mdown", "tasks/netzke_core_tasks.rake", "TODO"]
  s.files = ["autotest/discover.rb", "CHANGELOG", "generators/netzke_core/netzke_core_generator.rb", "generators/netzke_core/templates/create_netzke_layouts.rb", "generators/netzke_core/templates/create_netzke_preferences.rb", "generators/netzke_core/USAGE", "init.rb", "install.rb", "javascripts/core.js", "lib/app/controllers/netzke_controller.rb", "lib/app/models/netzke_layout.rb", "lib/app/models/netzke_preference.rb", "lib/netzke/action_view_ext.rb", "lib/netzke/base.rb", "lib/netzke/base_extras/interface.rb", "lib/netzke/base_extras/js_builder.rb", "lib/netzke/controller_extensions.rb", "lib/netzke/core_ext.rb", "lib/netzke/feedback_ghost.rb", "lib/netzke/routing.rb", "lib/netzke-core.rb", "lib/vendor/facets/hash/recursive_merge.rb", "LICENSE", "Manifest", "netzke-core.gemspec", "Rakefile", "README.mdown", "stylesheets/core.css", "tasks/netzke_core_tasks.rake", "test/app_root/app/controllers/application_controller.rb", "test/app_root/app/models/role.rb", "test/app_root/app/models/user.rb", "test/app_root/config/boot.rb", "test/app_root/config/database.yml", "test/app_root/config/environment.rb", "test/app_root/config/environments/in_memory.rb", "test/app_root/config/environments/mysql.rb", "test/app_root/config/environments/postgresql.rb", "test/app_root/config/environments/sqlite.rb", "test/app_root/config/environments/sqlite3.rb", "test/app_root/config/routes.rb", "test/app_root/db/migrate/20081222035855_create_netzke_preferences.rb", "test/app_root/db/migrate/20090423214303_create_roles.rb", "test/app_root/db/migrate/20090423222114_create_users.rb", "test/app_root/lib/console_with_fixtures.rb", "test/app_root/script/console", "test/fixtures/roles.yml", "test/fixtures/users.yml", "test/test_helper.rb", "test/unit/core_ext_test.rb", "test/unit/netzke_core_test.rb", "test/unit/netzke_preference_test.rb", "TODO", "uninstall.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://writelesscode.com}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Netzke-core", "--main", "README.mdown"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{netzke-core}
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Build ExtJS/Rails widgets with minimum effort}
  s.test_files = ["test/unit/core_ext_test.rb", "test/unit/netzke_core_test.rb", "test/unit/netzke_preference_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
