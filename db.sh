#!/bin/bash
### Script that handles customer info in iti database on MariaDB server
#BASH script manages user data
#	DataBase iti on MariaDB has 2 tables:
#					- iti.customers where id , name , mail of the customers are saved
#					- iti.accs where username and password of the authentication to run the file
#		
#	
#	Operations:
#		Add a customer
#		Delete a customer
#		Update a customer email
#		Query a customer
#	Notes:
#		Add,Delete, update need authentication
#		Query can be anonymous
#	Must be root to access the script
###################### TODO
#################################
### Exit codes:
##	0: Success
##	1: No access for database iti
##	2: No accs.db file exist
##	4: no read perm on accs.db
##	5: must be root to run the script
##	7: Customer name is not found
source ./password.sh
source ./checker.sh
source ./printmsgs.sh
source ./dbops.sh


AskForPass
pass=${?}


CheckAccessonDB
[ ${?} -eq 1 ] && printErrorMsg "Sorry, can not access database iti" &&  exit 1
checkFile "accs.db"
[ ${?} -ne 0 ] && printErrorMsg "Sorry, can not find accs.db" &&  exit 2
checkFileR "accs.db"
[ ${?} -ne 0 ] && printErrorMsg "Sorry, can not read from accs.db" &&  exit 4
checkUser "root"
[ ${?} -ne 0 ] && printErrorMsg "You are not root, change to root and come back" && exit 5
CONT=1
USERID=0
while [ ${CONT} -eq 1 ]
do
	printMainMenu
	read OP
	case "${OP}" in
		"a")
			echo "Authentication:"
			echo "---------------"
			echo -n "Username: "
			read ADMUSER
			echo -n "Password: "
			read -s ADMPASS
			authUser ${ADMUSER} ${ADMPASS}
			USERID=${?}
			if [ ${USERID} -eq 0 ] 
				then
					echo "Invalid username/password combination"
				else
					echo "Welcome to the system"
			fi

			;;
		"1")
			##### ADD NEW CUSTOMER TO THE DATABASE
			if [ ${USERID} -eq 0 ]
			then
				printErrorMsg "You are not authenticated, please authenticate 1st"
			else
				### TODO
					# check for id is valid integer
					# check for customer name is only alphabet,-_
					# check for email format
					# Check for userid exist or not
					# Check for email exist or not

				flag=0
				echo "Adding a new customer"
				echo "---------------------"
				echo -n "Enter customer ID : "
				read CUSTID
				CheckCustId ${CUSTID} 
				
				[ ${?} -ne 0 ] && printErrorMsg " ID must be an integer" && flag=1
				
				if [ ${flag} -eq 0 ] 
					then
						CheckUnique 'id' ${CUSTID} 
						[ ${?} -eq 1 ] && printErrorMsg " ID already exists" && flag=1
					fi
				
				if [ ${flag} -eq 0 ]
					then
						echo -n "Enter customer name : "
						read CUSTNAME
						flag=0
						CheckCustName ${CUSTNAME}	
						[ ${?} -ne 0 ] && printErrorMsg "Name must be alphapetical" && flag=1
					fi	
				
				if [ ${flag} -eq 0 ]
					then
				  		echo -n "Enter customer email : "
						read CUSTEMAIL
					
						flag=0
						CheckCustEmail ${CUSTEMAIL}
						[ ${?} -ne 0 ] && printErrorMsg "Invalid mail format" && flag=1
						[ ${flag} -eq 0 ] && CheckUnique 'mail' ${CUSTEMAIL} 
						[ ${?} -eq 1 ] && [ ${flag} -eq 0 ]  && printErrorMsg " Email already exists" && flag=1

  					fi
			
				if [ ${flag} -eq 0 ]
					then	
						echo "${CUSTID}:${CUSTNAME}:${CUSTEMAIL}" >> customers.db
						echo "customer ${CUSTID} saved locally in customers.db"
					fi
				if [ ${flag} -eq 0 ]
					then
						mysql -u esraa -p${pass} -e "insert into  iti.customers values (${CUSTID},'${CUSTNAME}','${CUSTEMAIL}');"
						echo "customer ${CUSTID} saved in data base"
			
				fi
			fi
			;;
		"2")
			########## UPDATE MAIL OF CERTAIN CUSTOMER ####################################
			if [ ${USERID} -eq 0 ]
                        then
                                printErrorMsg "You are not authenticated, please authenticate 1st"
			else
				echo "Updating an existing email"	
				#TODO
				#	Read required id to update
				#	check for valid integer
				#	check for id exists
				#	print details
				#	ask for confirmation
				# yes, 
					# ask for new email
					# check email is valid
					# check email exists
					# confirm
					# yes: update the email in the file
                        	
				
				flag=0
				echo "Enter your id"
				read CUSTID
				CheckCustId ${CUSTID}
                                [ ${?} -ne 0 ] && printErrorMsg " ID must be an integer" && flag=1

                                if [ ${flag} -eq 0 ]
                                        then
                                               CheckExistId ${CUSTID}
                                                [ ${?} -eq 1 ] &&  printErrorMsg " ID doesn't exist" && flag=1
					       	[ ${flag} -eq 0 ] && mysql -u esraa -p${pass} -e "select * from iti.customers where id=${CUSTID};"
                                        fi
				[ ${flag} -eq 0 ] && echo -e "Are you sure you want to update this record ?\n 0:for yes \n 1:for no" && read flag
				if [ ${flag} -eq 0 ]
					then
					
					echo -n  "Enter your new mail: "
					read CUSTNEWMAIL
					flag=0
					CheckCustEmail ${CUSTNEWMAIL}
					[ ${?} -ne 0 ] && printErrorMsg "Invalid mail format" && flag=1
                                        [ ${flag} -eq 0 ] && CheckUnique 'mail' ${CUSTNEWMAIL}
                                        [ ${?} -eq 1 ] && [ ${flag} -eq 0 ]&& printErrorMsg " Email already exists" && flag=1
				        [ ${flag} -eq 0 ] && echo -e "Are you sure you want to add this mail: ${CUSTNEWMAIL} ?\n 0:for yes \n 1:for no"
                        	        [ ${flag} -eq 0 ] && read flag
					[ ${flag} -eq 0 ] && UpdateRecord ${CUSTID} ${CUSTNEWMAIL} && echo "Successfully updated"
					[ ${flag} -ne 0 ]  && echo "NO change happen"	
				 else  
					 echo "invalid option"
				fi

				
			
			fi

			;;
		"3")
			############# DELETE EXISTING USER #############################
			if [ ${USERID} -eq 0 ]
                        then
                                printErrorMsg "You are not authenticated, please authenticate 1st"
			else
				echo "Deleting existing user"
				##ToOD
				#	Read required ID to delete
					# check for valid integer
					# check id exists
					# Print details
					# ask for confirmation
					# yes: Delete permanently
                        	flag=0
                                echo "Enter your id"
                                read CUSTID
                                CheckCustId ${CUSTID}
                                [ ${?} -ne 0 ] && printErrorMsg " ID must be an integer" && flag=1

                                if [ ${flag} -eq 0 ]
                                        then
                                               CheckExistId ${CUSTID}
                                                [ ${?} -eq 1 ] &&  printErrorMsg " ID doesn't exist" && flag=1
                                                [ ${flag} -eq 0 ] &&  mysql -u esraa -p${pass} -e "select * from iti.customers where id=${CUSTID};"
                                        fi

				[ ${flag} -eq 0 ] && echo -e "Are you sure you want to delete this record ?\n 0:for yes \n 1:for no" && read flag
                                if [ ${flag} -eq 0 ]
                                        then
						DeleteRecord ${CUSTID} && echo "Successfully deleted"
					fi
				[ ${flag} -ne 0 ]  && echo "NO change happen"
					
			
			
			fi
			;;
		"4")	
			###################### RETRIEVE A QUERY OF A CERTAIN USER ###################################
			echo -n "Enter your id : "
			read CUSTNAME
			queryCustomer ${CUSTNAME}
			;;
		"5")
			##################### EXIT THE SYSTEM ###############################
			echo "Thank you, see you later Bye"
			CONT=0
			;;
		*)
			echo "Invalid option, try again"
	esac
done



exit 0



