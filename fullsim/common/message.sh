#!/bin/bash

email=`whoami`
TMPDIR=/tmp/

mail -s "FULLSIM FINISHED" $email <<< "STEP \
 HAS FINISHED AND FILES CAN BE FOUND AT \
YOUR OUTPUT AREA."
