require 'redcarpet'

class Marker

  class << self
    attr_accessor :ext_opts, :marker
  end

  self.ext_opts = {
    no_intra_emphasis: true,
    autolink: true, 
    tables: true,
    fenced_code_blocks: true,
    strikethrough: true,
    lax_spacing: false,
    space_after_headers: false,
    superscript: true,
    underline: true,
    highlight: true,
    quote: true,
    footnotes: true,
  } 
  self.marker = Redcarpet::Markdown.new(Redcarpet::Render::HTML, self.ext_opts)
end
