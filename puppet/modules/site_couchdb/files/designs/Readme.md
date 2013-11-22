This directory contains design documents for the leap platform.

They need to be uploaded to the couch database in order to query the 
database in certain ways.

Each subdirectory corresponds to a couch database and contains the design
documents that need to be added to that particular database.

Here's an example of how to upload the users design document:
```bash
HOST="http://localhost:5984"
curl -X PUT $HOST/users/_design/User --data @users/User.json

```
