# This software is in the public domain, furnished "as is", without technical
# support, and with no warranty, express or implied, as to its usefulness for
# any purpose.

# Require this file to build a testing environment.

ABS__FILE__=File.expand_path(__FILE__)

$:.push(File.expand_path(__FILE__+'/../..'))
require 'extend/pathname'

# these are defined in global.rb, but we don't want to break our actual
# homebrew tree, and we do want to test everything :)
HOMEBREW_PREFIX=Pathname.new '/private/tmp/testbrew/prefix'
HOMEBREW_REPOSITORY=HOMEBREW_PREFIX
HOMEBREW_CACHE=HOMEBREW_PREFIX.parent+"cache"
HOMEBREW_CELLAR=HOMEBREW_PREFIX.parent+"cellar"
HOMEBREW_USER_AGENT="Homebrew"
HOMEBREW_WWW='http://example.com'
MACOS_VERSION=10.6

(HOMEBREW_PREFIX+'Library/Formula').mkpath
Dir.chdir HOMEBREW_PREFIX
at_exit { HOMEBREW_PREFIX.parent.rmtree }

# Test fixtures and files can be found relative to this path
TEST_FOLDER = Pathname.new(ABS__FILE__).parent.realpath

# Note: These exceptions duplicate those defined in globals.
# Perhaps the same definitions should be used in both places.
class ExecutionError <RuntimeError
  attr :exit_status
  attr :command

  def initialize cmd, args = [], es = nil
    @command = cmd
    super "Failure while executing: #{cmd} #{pretty(args)*' '}"
    @exit_status = es.exitstatus rescue 1
  end

  def was_running_configure?
    @command == './configure'
  end

  private

  def pretty args
    args.collect do |arg|
      if arg.to_s.include? ' '
        "'#{ arg.gsub "'", "\\'" }'"
      else
        arg
      end
    end
  end
end

class BuildError <ExecutionError
  attr :env

  def initialize cmd, args = [], es = nil
    super
    @env = ENV.to_hash
  end
end

require 'test/unit' # must be after at_exit
