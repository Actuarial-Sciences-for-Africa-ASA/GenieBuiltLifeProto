Architecture MVVM

### Transactions

Transaction data are persistent. 

Transactions are started 
* implicitly on creation of entities
* explicitly on existing entities

Once a transaction is open
* mutations can be savepointed.
* mutations can be persisted, Persising deletes prior savepoints and makes the persisted state a savepoint.
* it can be 
    * committed - provided data integrity rules are complied.
    * rolled back.
