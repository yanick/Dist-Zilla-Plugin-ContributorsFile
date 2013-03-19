
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "File::Find" => 0,
    "File::Temp" => 0,
    "Module::Build" => "0.3601",
    "Test::More" => "0.88"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "add a file listing all contributors",
  "dist_author" => [
    "Yanick Champoux <yanick\@cpan.org>"
  ],
  "dist_name" => "Dist-Zilla-Plugin-ContributorsFile",
  "dist_version" => "0.1.0",
  "license" => "perl",
  "module_name" => "Dist::Zilla::Plugin::ContributorsFile",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Dist::Zilla::File::InMemory" => 0,
    "Dist::Zilla::Role::FileGatherer" => 0,
    "Dist::Zilla::Role::Plugin" => 0,
    "Dist::Zilla::Role::TextTemplate" => 0,
    "Moose" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
