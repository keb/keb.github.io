local months = {
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
}

-- "2025-01-06" -> "January 06, 2025"
local function formatDate(date)
  local y, m, d = string.match(date, "^(%d+)-(%d+)-(%d+)")
  return months[string.toNumber(m)] .. " " .. d .. ", " .. y
end

-- Items with a date, newest first
local function sortedPosts(items)
  return table.sortBy(
    table.include(items, function (i) return i.date end),
    "date",
    true
  )
end

-- sets `date` and `file` (original filename) from "YYYY-MM-DD-slug.md" filenames
local function dateFromFilename(pattern)
  return deriveMetadata({
    file = function (item) return string.match(item.path, "([^/]+)$") end,
    date = function (item) return string.match(item.path, "(%d+-%d+-%d+)-[^/]+$") end,
  }, pattern)
end

-- builds a table of contents from each item's headings and stores it in `toc`.
-- `toc` is a list of top-level headings, each shaped like { id, title, children = { ...nested headings } }.
-- items whose path matches `options.anchors` also get a "#" link at the start of every heading.
local function headings(pattern, options)
  local class_name = "heading-anchor"
  options = options or {}

  return deriveMetadata({
    toc = function (item)
      -- add anchor links if options includes a filematch regex + and current file matches the regex
      local addAnchors = options.file_match and string.match(item.path, options.file_match)

      -- level 0 is never used, level 1 would be h1 headings, level 2 -> h2, and so on
      local root = { level = 0, children = {} }

      -- create the stack starting with the invisible root
      local stack = { root }

      -- for every heading in this .html file do:
      -- grab the `id` already provided by processMarkdown()
      item.content = string.gsub(item.content, "<h(%d) id=\"(.-)\">(.-)</h%1>", function (level, id, innerHTML)
        -- build node for this given heading
        local node = {
          level = string.toNumber(level),
          id = id,
          -- get title to show in the table of contents from the innerHTML
          -- remove any inner html tags
          title = string.gsub(innerHTML, "<.->", ""),
          children = {}
        }

        -- pop headings at the same or deeper level so the top of the stack is this heading's parent
        -- (e.g. an h2 that follows an h3 pops back up to the enclosing h1), then nest under it
        while stack[#stack].level >= node.level do
          table.remove(stack)
        end

        -- puts the heading into the tree, under its parent
        table.insert(stack[#stack].children, node)

        -- puts the heading on the stack, so it can become the parent of the next heading
        table.insert(stack, node)

        -- Returning nil leaves the heading unchanged
        if not addAnchors then
          return nil
        end

        local anchor = string.format("<a class=\"%s\" href=\"#%s\" aria-label=\"Anchor link for: %s\">#</a>", class_name, id, id)
        return string.format("<h%s id=\"%s\">%s%s</h%s>", level, id, anchor, innerHTML, level)
      end)

      return root.children
    end,
  }, pattern)
end

-- pretty URLs: "2019-05-18-foo.html" -> "foo/index.html" and sets `permalink` ("/foo/")
local function prettyPath(path)
  if string.match(path, "index%.html$") then return path end
  return (string.gsub(string.gsub(path, "%d+-%d+-%d+-([^/]+)$", "%1"), "%.html$", "/index.html"))
end

local function prettyUrls(pattern)
  return deriveMetadata({
    path = function (item)
      return prettyPath(item.path)
    end,

    permalink = function (item)
      return "/" .. string.gsub(prettyPath(item.path), "index%.html$", "")
    end,
  }, pattern)
end

-- adds a directory of scintillua lexers ahead of the built-in ones
local function addLexerPath(dir)
  package.path = dir .. "/?.lua;" .. package.path
end

return {
  addLexerPath = addLexerPath,
  formatDate = formatDate,
  sortedPosts = sortedPosts,
  dateFromFilename = dateFromFilename,
  headings = headings,
  prettyUrls = prettyUrls,
}
