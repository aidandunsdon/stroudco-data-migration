# Migration tool for OFN

### Usage

Configure the environment with source and database URLs:
```
export env SOURCE_DATABASE_URL="mysql2://user:password@host/db"
export env DESTINATION_DATABASE_URL="postgres://user:password@host/db"
```


Available commands:
```
  bin/ofn-migrate dump             # Dump data from the source database to file
  bin/ofn-migrate process          # Process last dump
  bin/ofn-migrate load             # Load data from files to the destination database
```


### TODO

* add migration ids to the destination database to support updates (source_id on spree_products, and others)
(SCHEMA mappings)

* write process_update and process_delete (comparison between two dumps are already done, just need the sequel code in load.rb)

* handle records that already exist in destination database by doing select before insert (duplicate emails, etc)

* add code to the Spree project to reset user's password.

