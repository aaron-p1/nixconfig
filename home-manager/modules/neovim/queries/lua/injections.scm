;; extends

((comment content: (_) @injection.language)
  . (string content: (_) @injection.content)
  (#gsub! @injection.language "%s*([%w%p]+)%s*" "%1"))
