(lambda fix-paste [old-paste]
  (fn [lines phase]
    (if (= phase -1)
        (do
          (if (= "" (. lines (length lines)))
              (table.remove lines))
          (old-paste lines phase))
        (old-paste lines phase))))

(fn setup []
  (set vim.paste (fix-paste vim.paste)))

{: setup}
