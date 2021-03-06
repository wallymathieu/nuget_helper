require_relative 'spec_helper'
require "tmpdir"
require "fileutils"
require "securerandom"
$vs_2013_solution = File.join(File.dirname(__FILE__), "Vs2013Solution", "Vs2013Solution.sln")

def magnitude_next_nuget_version(package_name, next_dll)
  begin
    tmp = File.join(Dir.tmpdir, SecureRandom.hex)
    NugetHelper.exec("install '#{package_name}' -o #{tmp} ")
    orig = Dir.glob( File.join(tmp, "**", File.basename(next_dll)) ).first
    path_to_package = Dir.glob( File.join(tmp, "*") ).first 
    v = SemVer.parse(path_to_package)
    m = NugetHelper.run_tool_with_result(NugetHelper.semver_fromassembly_path, " --magnitude #{orig} #{next_dll}").strip
    case m
    when 'Patch'
      v.patch += 1
      [:patch, v]
    when 'Major'
      v.major += 1
      [:major, v]
    when 'Minor'
      v.minor += 1
      [:minor, v]
    end
  ensure
    FileUtils.rm_rf(tmp)
  end
end

describe "magnitude_next_nuget_version" do
  before(:all) do
    NugetHelper.exec("restore #{$vs_2013_solution}")
  end
  xit "can give next version" do
    m, v = magnitude_next_nuget_version "SemVer.FromAssembly", NugetHelper.semver_fromassembly_path
    expect(m).to be :patch
    expect(v).to eq SemVer.new(0,0,9) # this is ugly, but will do for now
  end
end