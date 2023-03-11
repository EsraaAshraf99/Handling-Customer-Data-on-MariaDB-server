# Handling-Customer-Data-on-MariaDB-server
 Script that handles customer info in iti database on MariaDB server
 
This BASH script manages user data
DataBase iti on MariaDB has 2 tables:
                  - iti.customers where id , name , mail of the customers are saved
                  
                  - accs.db where username and password of the authentication to run the file


Operations:
###           Add a customer
###           Delete a customer
###           Update a customer email
###           Query a customer
Notes
- Add,Delete, update need authentication
- Query can be anonymous
- Must be root to access the script

