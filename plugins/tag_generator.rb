# A generator that creates tag pages for jekyll sites.
# (c) wo_is神仙 | http://MrZhang.me | MIT Licensed.
#
# Included filters :
# - tag_links: Outputs the list of tags as comma-separated <a> links.
#
# Available _config.yml settings :
# - tag_dir: The subfolder to build tag pages in (default is 'blog/tags').

require "stringex"

module Jekyll

  # The TagIndex class creates a single tag page for the specified tag.
  class TagIndex < Page

    # Initializes a new TagIndex.
    #
    #  +base+     is the String path to the <source>.
    #  +tag_dir+  is the String path between <source> and the tag folder.
    #  +tag+      is the tag currently being processed.
    def initialize(site, base, tag_dir, tag)
      @site = site
      @base = base
      @dir  = tag_dir
      @name = 'index.html'
      self.process(@name)
      # Read the YAML data from the layout page.
      self.read_yaml(File.join(base, '_layouts'), 'tag-index.html')
      self.data['tag']    = tag
      self.data['title']  = "Tag: #{tag}"
    end

  end

  # The Site class is a built-in Jekyll class with access to global site config information.
  class Site

    # Creates an instance of TagIndex for each tag page, renders it, and writes the output to a file.
    #
    #  +tag_dir+  is the String path to the tag folder.
    #  +tag+      is the tag currently being processed.
    def write_tag_index(tag_dir, tag)
      index = TagIndex.new(self, self.source, tag_dir, tag)
      index.render(self.layouts, site_payload)
      index.write(self.dest)
      # Record the fact that this page has been added, otherwise Site::cleanup will remove it.
      self.pages << index
    end

    # Loops through the list of tag pages and processes each one.
    def write_tag_indexes
      if self.layouts.key? 'tag-index'
        self.tags.keys.each do |tag|
          self.write_tag_index(File.join(self.config['tag_dir'], tag.to_url.downcase), tag)
        end

      # Throw an exception if the layout couldn't be found.
      else
        throw "No 'tag-index' layout found."
      end
    end

  end


  # Jekyll hook - the generate method is called by jekyll, and generates all of the tag pages.
  class GenerateTags < Generator
    safe true
    priority :low

    def generate(site)
      site.write_tag_indexes
    end

  end


  # Adds some extra filters used during the tag creation process.
  module Filters

    # Outputs a list of tags as comma-separated <a> links.
    # This is used to output the tag list for each post on a tag page,
    # and it supports chinese.
    #
    #  +tags+ is the list of tags to format.
    #
    # Returns string
    #
    def tag_links(tags)
      cfg = @context.registers[:site].config
      tags = tags.map do |tag|
        "<a href='/#{cfg['tag_dir']}/#{tag.to_url.downcase}/'>#{tag}</a>"
      end

      case tags.length
      when 0
        ""
      when 1
        tags[0].to_s
      else
        tags.join(', ')
      end
    end

  end

end