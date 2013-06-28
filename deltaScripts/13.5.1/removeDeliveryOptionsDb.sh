#!/bin/bash

SQL_SCRIPT="removeDeliveryOptions.sql"
# ensure that the sql script is present
if [ ! -f ${SQL_SCRIPT} ]; then
   echo "ERROR: the required sql script - ${SQL_SCRIPT} was not found."
   echo "FATAL: the update has failed!"
   exit 1
fi

echo "INFO: update started - removing delivery options from Subscription Manager"
# Update the database
/awips2/psql/bin/psql -U awips -d metadata -f ${SQL_SCRIPT}

if [ $? -ne 0 ]; then
   echo "FATAL: the update has failed!"
   exit 1
fi

echo "INFO: the update has completed successfully!"

exit 0
