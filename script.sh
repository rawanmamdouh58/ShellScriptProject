#!/bin/bash
DBs="$HOME/Documents/ShellScriptProject/DBs"

mkdir -p "$DBs" 

createDB(){
echo "Enter A Name Of New DB: " 
read name
if [ -z $name ]
then 
  echo "Error!! Database Name Can not Be Empty "
elif [ -d $DBs/$name ]
then
  echo "Error!! Database Name Is Already Exists"
else 
  mkdir $DBs/$name
  echo "Database $name created successfully."

fi

}
listDB(){
echo "List Of Databases:"
if [ -z "$(ls -A DBs)" ] 
then 
   echo "No DataBases Yet"
else 
 ls -1 $DBs #-1 => each db in a new line
fi
}

createTable(){
    echo "Enter A Table Name"
    read name
     
    if [ -z $name ]
    then 
        echo "Error!! Table Name Can Not Be Empty" 
    elif [ -f $name ]
    then
        echo "Error!! Table Name Already Exists"
  
    else
       echo "Enter Columns (use comma to sperate): "
        read columns
       echo "Enter Data Types (use comma to sperate): "
        read datatypes  
       
      
       numColumns=$(echo "$columns" | tr ',' '\n' | wc -l)
       numDatatypes=$(echo "$datatypes" | tr ',' '\n' | wc -l)
       
       while [ "$numDatatypes" -ne "$numColumns" ]
       do
         echo "Error!! You must provide a data type for each column. Please try again."
         echo "Enter Data Types (use comma to separate): "
         read datatypes
         numDatatypes=$(echo "$datatypes" | tr ',' '\n' | wc -l)
       done
       

         while true; do
            echo "Enter A Column As PK: "
            read pk
            if echo "$columns" | grep -qw "$pk"
            then
                break  
            else
                echo "Error!! Primary Key '$pk' is not a column. Please try again."
            fi
        done

       echo $columns > metadata.$name        
       echo $datatypes >>metadata.$name 
       echo $pk >> metadata.$name

        touch $name 
        echo "Table $name Created Successfully"
    fi

}



connectDB(){
echo "Enter The Name Of The DB To Connect : "
read name
if [ -d "$DBs/$name" ]
then 
  
  if cd "$DBs/$name" ;
   then 
     echo "Connection To $name Databse Successed"
  while true;
  do
  echo "Your Database Menu: "
  
   select item in "Create Table" "List Tables" "Insert Tables" "Select From Table" "Delete From Table" "Update Table" "Drop Table" "Exit"
   do
        case $item in 
            "Create Table")
              
                 createTable
                 break       
                   ;;
            "List Tables") 
                echo "Tables in Your DB Are:"
                ls -1 "$DBs/$name"                 
                 break
                   ;;
           
            "Insert Tables") 
                 
                 #break
                   ;;
            "Select From Table")
                 #break
                   ;;
            "Delete From Table")
                #break
                   ;;
            "Update Table")
                   ;;
            "Exit")
                 
                 break 2
                   ;;
            *) 
                 echo "Try Again With A Correct Option"   
                   ;;
        esac
   done
     echo "Enter To Continue"
     read
  done
   


  else
     echo "Error!! While Connection Try Again"
     exit 1
  fi
 
else
 
 echo "Error!! Database Name You Entered Not Exist!" 
fi 

}

dropDB(){
echo "Enter The Database Name You Want To Drop : "
read name
if [ -d $DBs/$name ]
then 
 
 if [ ! -z "$(ls -A DBs/$name)" ]
 then 
    
     echo "Database Not Empty. Are You Sure To Drop ? y/n "
   read answer
   if [ $answer == "y" ]
   then 
     rm -r $DBs/$name    
     echo "Database Dropped Successfully"
     
   else 
     echo "Drop DB Canceled" 
    
   fi  
 else
   rmdir $DBs/$name
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
