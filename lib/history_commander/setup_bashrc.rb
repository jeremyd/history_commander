require 'rubygems'
require 'fileutils'
require 'trollop'
require 'highline/import'

class SetupBashrc
  # Install necessary .bashrc customization for optimal history commander usage.
  def self.install(force = false)
    my_home = File.expand_path('~')
    my_bashrc = File.join(my_home, ".bashrc")
    unless File.exists?(my_bashrc)
      if File.exists?("/etc/bashrc")
        FileUtils.cp("/etc/bashrc", my_bashrc)
      elsif File.exists?("/usr/etc/bashrc")
        FileUtils.cp("/usr/etc/bashrc", my_bashrc)
      else
        `touch #{my_bashrc}` 
      end
    end
    say "using .bashrc in #{my_bashrc}"
    self.apply_change(my_bashrc, force)
  end

  def self.goodies
    <<eoh
shopt -s histappend
export HIST_CONTROL=ignoreboth
export PROMPT_COMMAND="history -a; history -n"
export HISTSIZE=1000000 
export HISTFILESIZE=1000000
eoh
  end

  def self.do_warnings(file_contents)
    if file_contents =~ /#{self.goodies}/
      say "*** WARNING: modifications already installed!"
    end
    if file_contents =~ /PROMPT_COMMAND/
      say "*** WARNING: your .bashrc already has a PROMPT_COMMAND.  This setting will be overridden!"
    end
  end

  # *file <~String>: bashrc file to detect and optionally apply changes to.
  def self.apply_change(file, force = false)
    say("Thanks for installing History Commander!\nThe following modifications will be applied to your ~/.bashrc file:")
    say("+++\n#{self.goodies}")
    self.do_warnings(IO.read(file))
    unless force
      confirm = ask("+++ Apply changes (y/n)?", lambda { |ans| true if (ans =~ /^[y,Y]{1}/) })
      unless confirm
        say "Aborting."
        exit
      end
    end
    backup = "#{file}_hc_backup#{rand(10000)}"
    say "Creating backup of .bashrc in #{backup}"
    FileUtils.cp(file, backup)
    File.open(file, "a") { |f| f.puts(self.goodies)}
    say "done installing history customization."
    say "***"
    say "Now you MUST load your new bash history config:"
    say "Open a new terminal -or-" 
    say "'source #{file}'"
  end
end
