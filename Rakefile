require 'echoe'

Echoe.new("netzke-core") do |p|
  p.author = "Sergei Kozlov"
  p.email = "sergei@writelesscode.com"
  p.summary = "Build ExtJS/Rails widgets with minimum effort"
  p.url = "http://writelesscode.com"
  p.development_dependencies = []
  p.test_pattern = 'test/**/*_test.rb'
  p.retain_gemspec = true
  
  # fixing the problem with lib/*-* files being removed while doing manifest
  p.clean_pattern = ["pkg", "doc", 'build/*', '**/coverage', '**/*.o', '**/*.so', '**/*.a', '**/*.log', "{ext,lib}/*.{bundle,so,obj,pdb,lib,def,exp}", "ext/Makefile", "{ext,lib}/**/*.{bundle,so,obj,pdb,lib,def,exp}", "ext/**/Makefile", "pkg", "*.gem", ".config"]
end
