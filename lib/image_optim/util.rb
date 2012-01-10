class ImageOptim
  module Util
    # Run command redirecting both stdout and stderr to /dev/null, raising signal if command was signaled and return successfulness
    def self.run(*args)
      res = system "#{args.map(&:to_s).shelljoin} &> /dev/null"
      if $?.signaled?
        raise SignalException.new($?.termsig)
      end
      res
    end

    # http://stackoverflow.com/questions/891537/ruby-detect-number-of-cpus-installed
    def self.processor_count
      @processor_count ||= case host_os = RbConfig::CONFIG['host_os']
      when /darwin9/
        `hwprefs cpu_count`
      when /darwin/
        (`which hwprefs` != '') ? `hwprefs thread_count` : `sysctl -n hw.ncpu`
      when /linux/
        `grep -c processor /proc/cpuinfo`
      when /freebsd/
        `sysctl -n hw.ncpu`
      when /mswin|mingw/
        require 'win32ole'
        wmi = WIN32OLE.connect('winmgmts://')
        cpu = wmi.ExecQuery('select NumberOfLogicalProcessors from Win32_Processor')
        cpu.to_enum.first.NumberOfLogicalProcessors
      else
        warn "Unknown architecture (#{host_os}) assuming one processor."
        1
      end.to_i
    end
  end
end