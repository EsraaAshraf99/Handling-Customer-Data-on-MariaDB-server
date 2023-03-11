source ./password.sh
AskForPass
pass=${?}

##Function takes a parameters. which is file name and return 0 if the file exists
function checkFile {
	FILENAME=${1}
	[ ! -f ${FILENAME} ] && return 1
	return 0
}
##Function takes a parameter which is filename and return 0 if the file has read perm
function checkFileR {
	FILENAME=${1}
	[ ! -r ${FILENAME} ] && return 1
	return 0
}
##Function takes a paremter which is filename and returns 0 if the file has write permission
function checkFileW {
	FILENAME=${1}
        [ ! -w ${FILENAME} ] && return 1
        return 0
}

## Function takes a parameter with username, and return 0 if the user requested is the same as current user
function checkUser {
	RUSER=${1}
	[ ${RUSER} == ${USER} ] && return 0
	return 1
}

### Function takes a username, and password then check them in accs.db, and returns 0 if match otherwise returns 1
function authUser {
	USERNAME=${1}
	USERPASS=${2}
	###1-Get the password hash from accs.db for this user if user found
	###2-Extract the salt key from the hash
	###3-Generate the hash for the userpass against the salt key
	###4-Compare hash calculated, and hash comes from the file.
	###5-IF match returns 0,otherwise returns 1
	USERLINE=$(grep ":${USERNAME}:" accs.db)
	[ -z ${USERLINE} ] && return 0
	PASSHASH=$(echo ${USERLINE} | awk ' BEGIN { FS=":" } { print $3} ')
	SALTKEY=$(echo ${PASSHASH} | awk ' BEGIN { FS="$" } { print $3 } ')
	NEWHASH=$(openssl passwd -salt ${SALTKEY} -6 ${USERPASS})
	if [ "${PASSHASH}" == "${NEWHASH}" ]
	then
		USERID=$(echo ${USERLINE} | awk ' BEGIN { FS=":" } { print $1} ')
		return ${USERID}
	else
		return 0
	fi
}



### Function that takes user id and return 0 if integer , other wise it returns 1


function CheckCustId {
	ID=${1}
	count=$(echo ${ID} | grep -c  ^[0-9]*$)
	[ ${count} -eq 1 ] && return 0
	[ ${count} -ne 1 ] && return 1

}

### Function that takes user name and return 0 if alphapetical , other wise it returns 1


function  CheckCustName {
	NAME=${1}
	count=$(echo ${NAME} | grep -c ^[a-z]*$)
	[ ${count} -eq 1 ] && return 0
        [ ${count} -ne 1 ] && return 1

}


### Function that takes user mail and return 0 if format is valid , other wise it returns 1


function CheckCustEmail { 
	MAIL=${1}
	count=$(echo ${MAIL} | grep -c ^[a-zA-Z]*[0-9]*[a-z]*@[a-z]*.com$)
        [ ${count} -eq 1 ] && return 0
        [ ${count} -ne 1 ] && return 1



}

### Function that takes 2 parameters :
#                               - the first parameter is option to switch inside in case , it could be id or mail
#                               - the second parameters is values of the id or the mail
#   It return 0 if the value is repeated and return 1 if the values is unique



function CheckUnique {
out=0
option=${1}
value=${2}
case "${option}" in 
	"id")

		################# if i read from my database
		name=$(mysql -u esraa -p${pass} -e "select name from iti.customers where id=${value};" | sed '1d')
	#	echo "name=${name} , id=${value}"
		[ -n "${name}"  ] && out=1
	#	echo "out=${out}"

	;;
			
	"mail")

		mail=$(mysql -u esraa -p${pass} -e "select name from iti.customers where mail='${value}';" | sed '1d')
		[ -n "${mail}"  ] && out=1

        ;;
esac
[ ${out} -eq 1 ] && return 1
[ ${out} -eq 0 ] && return 0

}

### Function that takes user id and return 0 if id exists in MariaDB , other wise it returns 1


function  CheckExistId {
	record=0
	value=${1}

	name=$(mysql -u esraa -p${pass} -e "select name from iti.customers where id=${value};" | sed '1d')
	[ -n "${name}"  ] && record=1

	[ ${record} -eq 0 ] && return 1
	return 0	
}

### Function that update the mail in the MariaDB , it takes 2 parameters:
#                                                                       - The first parameters is the id
#                                                                       - The second parameter is th new mail value
#   It has no return but it replaces the old mail with new one in database file



function  UpdateRecord {
id=${1}
newmail=${2}

		mysql -u esraa -p${pass} -e "update  iti.customers set mail='${newmail}' where id=${id};"


}


### Function that delete a record from MariaDB , it take the id from user
#   It has no return but it delete the record from database file



function DeleteRecord {
	id=${1}
		 mysql -u esraa -p${pass} -e "delete from iti.customers where id=${id};"
	


}




function CheckAccessonDB {
	y=$(mysql -u esraa -p123 iti -e  "select * from customers where id=1 " | grep ERROR)
	echo ${y}
	[ -n "${y}" ] && return 1
	return 0
}


