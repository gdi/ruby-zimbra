Gem::Specification.new do |s|
  s.name = "zimbra"
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Derek Kastner","Matt Wilson"]
  s.date = '2009-11-18'
  s.description = 'Interface to Zimbra management API'
  s.email = %q{derek@vedit.com mwilson@vedit.com}
  s.files = ['README'] + Dir.glob("lib/**/*.rb")
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{SOAP Interface to Zimbra}
  s.add_development_dependency('rspec')
  s.add_dependency('handsoap')

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2
  end
end
