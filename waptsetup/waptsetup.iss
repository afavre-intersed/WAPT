#define edition "waptsetup"
#define default_repo_url ""
#define default_wapt_server ""
#define repo_url ""
#define wapt_server ""
#define AppId "WAPT"
#define AppName "WAPTSetup"
#define output_dir "."
#define Company "Tranquil IT Systems"
#define send_usage_report 0

; if not empty, set value 0 or 1 will be defined in wapt-get.ini
#define set_use_kerberos "0"

; if empty, a task is added
; copy authorized package certificates (CA or signers) in <wapt>\ssl
#ifndef set_install_certs
#define set_install_certs ""
#endif

; if 1, expiry and CRL of package certificates will be checked
#define check_certificates_validity 1

; if not empty, the 0, 1 or path to a CA bundle will be defined in wapt-get.ini for checking of https certificates
#define set_verify_cert "0"

; default value for detection server and repo URL using dns 
#define default_dnsdomain ""

; if not empty, a task will propose to install this package or list of packages (comma separated)
#ifndef set_start_packages
#define set_start_packages ""
#endif


;#define waptenterprise

#ifndef set_disable_hiberboot
#define set_disable_hiberboot ""
#endif

;#define signtool "kSign /d $qWAPT Client$q /du $qhttp://www.tranquil-it-systems.fr$q $f"

; for fast compile in developent mode
;#define FastDebug

#include "common.iss"
