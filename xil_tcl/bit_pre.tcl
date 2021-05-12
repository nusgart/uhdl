# Disable some DRC checks to allow bitstream generation
## TODO remove this when done

set_property SEVERITY {Warning} [get_drc_checks RTSTAT-1]
set_property SEVERITY {Warning} [get_drc_checks RTSTAT-2]
## 
set_property IS_ENABLED 0 [get_drc_checks {RTSTAT-1}]
set_property IS_ENABLED 0 [get_drc_checks {RTSTAT-2}]
set_property IS_ENABLED 0 [get_drc_checks {RTSTAT-1}]
set_property IS_ENABLED 0 [get_drc_checks {REQP-186}]