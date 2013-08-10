require "rake"

Gem::Specification.new do |gem|
	gem.name = "mfjen"
	gem.version = "0.0.1"
	gem.summary = "A Makefile generator."
	gem.authors = ["Kristofer Rye", "Sam Craig"]
	gem.email = "sammidysam@gmail.com"
	gem.files = FileList["Rakefile", "lib/**/*.rb", "bin/*"].to_a
	#gem.homepage = "http://sammidysam.github.io/2013/08/01/mfjen.html"
	gem.license = "gpl-3.0"
end
