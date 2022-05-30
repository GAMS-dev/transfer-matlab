#!/usr/bin/expect

set matlab_command [lindex $argv 0];
set timeout 180

spawn matlab -nodesktop -batch "$matlab_command"

expect "Please enter your MathWorks Account email address and press Enter:\r"
send -- "_matlab_username_\r"

expect "Please enter your MathWorks Account password and press Enter:\r"
send -- "_matlab_password_\r"

expect eof
catch wait result
exit [lindex $result 3]
