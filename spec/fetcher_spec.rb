require File.join(File.dirname(__FILE__), "spec_helper")

describe "Fetcher" do
  before(:each) do
    @source = URI.parse("file://#{File.expand_path(File.dirname(__FILE__))}/fixtures")
    @other  = URI.parse("file://#{File.expand_path(File.dirname(__FILE__))}/fixtures2")
    @finder = Bundler::Finder.new(@source, @other)
  end
  
  it "stashes the source in the returned gem specification" do
    @finder.search(Gem::Dependency.new("abstract", ">= 0")).first.source.should == @source
  end

  it "uses the first source that was passed in if multiple sources have the same gem" do
    @finder.search(build_dep("activerecord", "= 2.3.2")).first.source.should == @source
  end

  it "raises if the source is invalid" do
    lambda { Bundler::Finder.new.fetch("file://not/a/gem/source") }.should raise_error(ArgumentError)
    lambda { Bundler::Finder.new.fetch("http://localhost") }.should raise_error(ArgumentError)
    lambda { Bundler::Finder.new.fetch("http://google.com/not/a/gem/location") }.should raise_error(ArgumentError)
  end
  
  it "accepts multiple source indexes" do
    @finder.search(Gem::Dependency.new("abstract", ">= 0")).size.should == 1
    @finder.search(Gem::Dependency.new("merb-core", ">= 0")).size.should == 2
  end
  
  it "resolves rails" do
    specs = @finder.resolve(build_dep('rails', '>= 0'))
    specs.should match_gems(
      "rails"          => ["2.3.2"],
      "actionpack"     => ["2.3.2"],
      "actionmailer"   => ["2.3.2"],
      "activerecord"   => ["2.3.2"],
      "activeresource" => ["2.3.2"],
      "activesupport"  => ["2.3.2"],
      "rake"           => ["0.8.7"]
    )
    
    specs.select { |spec| spec.name == "activeresource" && spec.source == @other }.should have(1).item
    specs.select { |spec| spec.name == "activerecord" && spec.source == @source }.should have(1).item
  end
end