(local {: autocmds : purge} (require :skip.utils))

(fn make-pawline-opts []
  "Returns pawline's heirline options."
  ((-> (require :skip.pawline) (. :make-opts))))

(fn load-pawline []
  "Loads pawline's heirline options and passes it into heirline.setup."
  ((-> (require :heirline) (. :setup)) (make-pawline-opts)))

(fn pawline-purge-reload []
  "Clears pawline from the package cache and loads it."
  (purge "^skip%.pawline")
  (load-pawline))

(fn void [f]
  "Compels a function to always return nil."
  (fn [...] (f ...) nil))

(fn config [plugin opts]
  (load-pawline)
  (autocmds :HeirlineReload
            [[:BufWritePost
              {:pattern :*/pawline.fnl
               :callback (void pawline-purge-reload)
               :desc "Reload pawline"}]]))

[{1 :rebelot/heirline.nvim
  :event :VeryLazy
  :dependencies [:nvim-tree/nvim-web-devicons]
  :opts make-pawline-opts
  : config}]

