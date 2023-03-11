## Function, takes customer name, and prints out the id, name, and email. Returns 0 if found, otherwise return 1
function queryCustomer {
	local id=${1}
	 name=$(mysql -u esraa -p123 -e "select name from iti.customers where id=${id};" | sed '1d')
	  [ -z ${name} ] && printErrorMsg "Sorry, ${id} is not found" && return 7
	  echo "Information for the customer"
	  mysql -u esraa -p123 -e "select * from iti.customers where id=${id} ;"
	  return 0
}


