local plugin = fs.doThemeFile("theme/plugins.lua")

local site = {
  title = "keb",
  url = "https://keb.im/",
}

return {
  -- read from content/ dir, and static/ dir straight -> output dir
  readFromSource("content"),
  readFromSource("static"),

  -- add empty items for pages with no source file; their templates fill them in below
  injectFiles({ ["404.html"] = "" }),

  -- for posts, set `date` ("2019-05-18") and `file` ("2019-05-18-foo.md") from the filename
  plugin.dateFromFilename("^[^/]+%.md$"),

  -- parse frontmatter into item fields, convert Markdown to HTML, and rename *.md to *.html
  -- in our case, the only *.md files we process are the ones we read earlier in `readFromSource("content")`
  processMarkdown(),

  -- add table of contents for each page, and add "#" anchor links to headings in blog posts
  plugin.headings("%.html$", { file_match = "^%d+-%d+-%d+-" }),

  -- move pages to pretty URL paths ("2019-05-18-foo.html" -> "foo/index.html")
  plugin.prettyUrls(function (item) return string.find(item.path, "%.html$") and item.path ~= "404.html" end),

  -- create the home page and feed, each with an `items` list of all posts
  -- `items` gets passed to whatever template is used to build the respective file (see below `applyTemplates` call)
  -- note: since at this point we've already processed the markdown -> html, and used prettyUrls, we look for */index.htmls
  aggregate("index.html", "^[^/]+/index%.html$"),
  aggregate("atom.xml", "^[^/]+/index%.html$"),

  -- make site info and helper functions available to every template
  injectMetadata({
    site = site,
    sortedPosts = plugin.sortedPosts,
    formatDate = plugin.formatDate
  }),

  -- render the feed first, on its own, so the HTML templates below never apply to it
  applyTemplates({ { "^atom%.xml$", fs.readThemeFile("theme/templates/atom.etlua") } }),

  applyTemplates({
    { "^[^/]+/index%.html$", fs.readThemeFile("theme/templates/post.etlua") },
    { "^index%.html$", fs.readThemeFile("theme/templates/index.etlua") },
    { "^404%.html$", fs.readThemeFile("theme/templates/404.etlua") },
  }),

  -- apply layout templates
  applyTemplates({
    { "%.html$", fs.readThemeFile("theme/templates/base.etlua") }
  }),

  -- write every item to public/ at its path
  writeToDestination("public"),
}
