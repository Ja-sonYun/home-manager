require('modules.utils').set_buffer_opts { width = 2, is_code = true }

require('modules.formatter').register("awk", "awk --pretty-print=%.tmp -f % && mv %.tmp %")
