#!/bin/bash
DBs="~/Documents/ShellScriptProject"
createDB(){
echo "Enter A Name Of New DB: " 
read name
if [ -z $name ]
then 
  echo "Error!! Database Name Can not Be Empty "
elif [ -d DBs/$name ]
then
  echo "Error!! Database Name Is Already Exists"
else 
  mkdir DBs/$name
  echo "Database $name created successfully."

fi

}
listDB(){
echo "List Of Databases:"
if [ -z "$(ls -A DBs)" ] 
then 
   echo "No DataBases Yet"
else 
 ls -1 DBs
fi
}


connectDB(){
echo "Enter The Name Of The DB To Connect : "
read name
if [ -d DBs/$name ]
then 
  
  if cd DBs/$name
  then 
     echo "Connection To $name Databse Successed"
  else
     echo "Error!! While Connection Try Again"
     exit 1
  fi
 
else echo "Error!! Database Name You Entered Not Exist!" 
fi 

}

dropDB(){
echo "Enter The Database Name You Want To Drop : "
read name
if [ -d DBs/$name ]
then 
 
 if [ ! -z "$(ls -A DBs/$name)" ]
 then 
    #echo "Are You Sure To Drop DB? y/n"
     echo "Database Not Empty. Are You Sure To Drop ? y/n "
   read answer
   if [ $answer == "y" ]
   then 
     rm -r DBs/$name    
     echo "Database Dropped Successfully"
     
   else 
     echo "Drop DB Canceled" 
    
   fi  
 else
   rmdir DBs/$name
   echo "Database Dropped Successfully"
 fi
else echo "Error!! Database Name You Entered Not Exist!" 
fi    
}

while true;
do
echo "Main Menu: "

select item in "Create Database" "List Database" "Connect To Database" "Drop Database" "Exit"
do
  case $item in 
     "Create Database")
         createDB
         break         
       ;;
     "List Database") 
        listDB
        break
       ;;
     "Connect To Database")
        connectDB
        break        
       ;;
     "Drop Database") 
        dropDB
        break
       ;;
     "Exit")
        exit 0 
       ;;
     *) 
        echo "Try Again With A Correct Option"   
       ;;
  esac
done
  echo "Enter To Continue"
  read
done
