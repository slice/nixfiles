(fn icon []
  (fn init [{: filename &as self}]
    (let [get-icon-color (-> (require :nvim-web-devicons) (. :get_icon_color))]
      (->> (vim.fn.fnamemodify filename ":e") ; get extension
           (#(get-icon-color filename $ {:default true}))
           (set (self.icon self.icon_color)))))

  {: init :provider #(.. $.icon " ")})

(local blocks
       {:mode #{:init #(set $1.mode (vim.fn.mode))}
        :filename #{:init #(set $1.filename (vim.api.nvim_buf_get_name 0))}})

(local symbols {:tri-bl "" :tri-br "" :tri-tl "" :tri-tr ""})

(fn wolf []
  (fn emit-icon [escape] (.. escape " "))

  {:provider (.. " " (emit-icon " ") "")})

(fn mode []
  (fn expand-mode [mode]
    (case mode
      :n :NRM
      :i :INS
      :v :VZL
      :^v :VZB
      :c :CMD))

  {:provider (let []
               #(.. symbols.tri-tl " " (or (expand-mode $.mode) $.mode) " "
                    symbols.tri-br))
   :hl :StatusLineNC
   :update [:ModeChanged]})

(fn filename []
  (fn provider [{:filename name}]
    (-> (vim.fn.fnamemodify name ":~:.")
        (#(if (= $ "") "[nothing]" $))
        (#(.. " " $ " "))))

  {: provider
   :hl #(if (= $.filename "") {:italic true :bold false :force true} nil)
   :update [:BufEnter :DirChanged]})

(fn make-opts []
  (fn disable-winbar-callback [{: conditions}]
    (fn [args]
      (conditions.buffer_matches {:buftype [:nofile :prompt]} args.buf)))

  (let [conditions (require :heirline.conditions)
        utils (require :heirline.utils)
        ctx {: conditions : utils :within utils.insert}
        {: within} ctx]
    {:statusline [(within (blocks.mode) (wolf ctx) (mode ctx))
                  (within (blocks.filename) (filename ctx))]
     ;; :winbar [(within (blocks.filename) (icon ctx) (filename ctx))]
     :opts {:disable_winbar_cb (disable-winbar-callback ctx)}}))

{: make-opts}

