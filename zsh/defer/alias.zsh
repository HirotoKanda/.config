function fix_clock() {
  sudo rm /var/db/timed/com.apple.timed.plist; 
  sudo kill $(ps -axo pid,comm | grep '/usr/libexec/timed' | awk '{print $1}'); 
  sudo sntp -sS ntp.nict.jp; 
}
alias fix_clock=fix_clock
