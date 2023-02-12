(local {: endswith :api {: nvim_buf_get_name : nvim_get_current_line}} vim)

(local line-pattern "^%s*%(u ")
(local replace-pattern "^https://github.com/([^/]+/[^/]+).*$")
(local replacement "%1")

(lambda should-paste [lines]
  (and (= 1 (length lines)) (endswith (nvim_buf_get_name 0) :/init.fnl)
       (string.match (nvim_get_current_line) line-pattern)))

(fn new-paste [old-paste [first-line &as lines] phase]
  (if (should-paste lines)
      (let [new-line (string.gsub first-line replace-pattern replacement)]
        (old-paste [new-line] phase))
      (old-paste lines phase)))

(fn setup []
  (let [overridden vim.paste]
    (set vim.paste (partial new-paste overridden))))

{: setup}
