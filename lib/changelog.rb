# encoding: utf-8

class CHANGELOG
  # @param [String] path Path to your CHANGELOG file
  # @raise [ArgumentError] if given path doesn't exist
  # @author Jakub Stastny aka Botanicus
  # @since 0.0.1
  def initialize(path = "CHANGELOG")
    raise ArgumentError, "Path '#{path}' doesn't exist!" unless File.exist?(path)
    @path = path
  end

  # @return [Array<String>] List of all the available versions
  # @author Jakub Stastny aka Botanicus
  # @since 0.0.1
  def versions
    self.parse.keys
  end

  # @return [String, nil]
  #   Name of the last available version or nil if the changelog is empty
  # @author Jakub Stastny aka Botanicus
  # @since 0.0.1
  def last_version_name
    self.versions.last
  end

  # @return [Array<String>, nil]
  #   List of changes in the last version or nil if the changelog is empty
  # @author Jakub Stastny aka Botanicus
  # @since 0.0.1
  def last_version_changes
    self.parse[self.versions.last]
  end

  # @param [String, Regexp] version Full name of the version or pattern matching the version.
  # @raise [StandardError] if pattern matched more than one version
  # @return [Array<String>, nil]
  #   List of changes in the given version or nil if given version doesn't exist
  # @example changelog["Version 0.1"]
  # @author Jakub Stastny aka Botanicus
  # @since 0.0.1
  def [](version)
    if version.is_a?(String)
      self.parse[version]
    else
      versions = self.select(version).keys
      if versions.length > 1
        raise StandardError, "More than one version was matched: #{versions.inspect}"
      elsif versions.empty?
        return nil
      else
        self[versions.first]
      end
    end
  end

  # @param [String, Regexp] version Pattern we want to match in version.
  # @return [Hash] Hash of `{version => changes}` for matched versions.
  # @example changelog.select(/^Version 0.1.\d+$/)
  # @author Jakub Stastny aka Botanicus
  # @since 0.0.1
  def select(pattern)
    self.parse.select do |version, changes|
      version.match(pattern)
    end
  end

  # @return [Hash] Hash of `{version => changes}` for the whole changelog.
  # @author Jakub Stastny aka Botanicus
  # @since 0.0.1
  def parse
    @result ||= begin
      lines = File.readlines(@path)
      lines.inject([nil, Hash.new]) do |pair, line|
        version, hash = pair
        if line.match(/^=/)
          version = line.chomp.sub(/^= /, "")
          hash[version] = Array.new
        elsif line.match(/^\s+\* /)
          hash[version].push(line.chomp.sub(/^\s+\* /, ""))
        else # skip empty lines
        end
        [version, hash]
      end.last
    end
  end
end