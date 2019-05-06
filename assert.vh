`define assert(signal, value) \
if (signal !== value) begin \
   $display("ASSERTION FAILED in %m: signal != value"); \
   $finish; \
end
 
`define warn(signal, value) \
if (signal !== value) begin \
   $display("WARNING in %m: signal != value"); \
end

// Add the following: 
//	emerg(args...)		syslog(LOG_EMERG, ##args)
//	alert(args...)		syslog(LOG_ALERT, ##args)
//	crit(args...)		syslog(LOG_CRIT, ##args)
//	err(args...)		syslog(LOG_ERR, ##args)
//	warning(args...)	syslog(LOG_WARNING, ##args)
//	notice(args...)		syslog(LOG_NOTICE, ##args)
//	info(args...)		syslog(LOG_INFO, ##args)
//	debug(args...)		syslog(LOG_DEBUG, ##args)
