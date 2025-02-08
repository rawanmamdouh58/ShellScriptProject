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
if [ -z "$(ls DBs)" ] 
then 
   echo "No DataBases Yet"
else 
 ls -1 $DBs #-1 => each db in a new line
fi
}

createTable(){
    echo "Enter A Table Name"
    read table_name
     
    if [ -z $table_name ]
    then 
        echo "Error!! Table Name Can Not Be Empty" 
    elif [ -f $table_name ]
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

       echo $columns > metadata.$table_name        
       echo $datatypes >>metadata.$table_name 
       echo $pk >> metadata.$table_name 

        echo "$columns" > $table_name 
        echo "Table $table_name Created Successfully"
    fi

}



connectDB(){
echo "Enter The Name Of The DB To Connect : "
read db_name
if [ -d "$DBs/$db_name" ]
then 
  
  if cd "$DBs/$db_name" ;
   then 
     echo "Connection To $db_name Databse Successed"
  while true;
  do
  echo "Your Database Menu: "
  
   select item in "Create Table" "List Tables" "Insert Into Tables" "Select From Table" "Delete From Table" "Update Table" "Drop Table" "Exit"
   do
        case $item in 
            "Create Table")
              
                 createTable
                 break       
                   ;;
            "List Tables") 
                echo "Tables in Your DB Are:"
                ls -1 "$DBs/$db_name"                 
                 break
                   ;;
            "Insert Into Tables") 
                insertIntoTable 
                break
                   ;;
            "Select From Table")
                 #break
                   ;;
            "Delete From Table")
                #break
                   ;;
            "Update Table")
                   ;;
	   "Drop Table")
		dropTable
		break
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

insertIntoTable(){
    echo "Enter Table Name You Want To Insert Into: "
    read table_name

    if [ ! -f "$table_name" ]; then
        echo "Error!! Table '$table_name' Does Not Exist!"
        return
    fi

    columns=$(sed -n '1p' "metadata.$table_name")
    datatypes=$(sed -n '2p' "metadata.$table_name")
    pk=$(sed -n '3p' "metadata.$table_name")

    numColumns=$(echo "$columns" | tr ',' '\n' | wc -l)
    
    echo "Columns: $columns"
    echo "Enter Values Separated By Commas: "
    read values

    numValues=$(echo "$values" | tr ',' '\n' | wc -l)

    if [ "$numValues" -ne "$numColumns" ]; then
        echo "Error!! Number of Values Does Not Match Number of Columns!"
        return
    fi

    IFS=',' read -ra colArr <<< "$columns"
    IFS=',' read -ra typeArr <<< "$datatypes"
    IFS=',' read -ra valArr <<< "$values"

    for i in "${!typeArr[@]}"; do
        case "${typeArr[$i]}" in
            int)
                if ! [[ "${valArr[$i]}" =~ ^[0-9]+$ ]]; then
                    echo "Error!! Column '${colArr[$i]}' Requires an Integer Value!"
                    return
                fi
                ;;
            string)
                if ! [[ "${valArr[$i]}" =~ ^[a-zA-Z0-9]+$ ]]; then
                    echo "Error!! Column '${colArr[$i]}' Requires a String!"
                    return
                fi
                ;;
            float)
                if ! [[ "${valArr[$i]}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
                    echo "Error!! Column '${colArr[$i]}' Requires a Float Value!"
                    return
                fi
                ;;
            *)
                echo "Error!! Unknown Data Type for Column '${colArr[$i]}'!"
                return
                ;;
        esac
    done

    pkIndex=-1
    for i in "${!colArr[@]}"; do
        if [[ "${colArr[$i]}" == "$pk" ]]; then
            pkIndex=$i
            break
        fi
    done

    if [[ $pkIndex -ne -1 ]]; then
        pkValue="${valArr[$pkIndex]}"
        if grep -q "^$pkValue," "$table_name"; then
            echo "Error!! Primary Key '$pk' Value '$pkValue' Already Exists!"
            return
        fi
    fi
    echo "$values" >> "$table_name"
    echo "Data Inserted Successfully!"
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


dropTable(){
    echo "Enter The Table Name You Want To Drop: "
    read table_name

    if [ -f "$DBs/$db_name/$table_name" ]; 
	then
        echo "Are You Sure You Want To Drop Table '$table_name'? (y/n)"
        read answer
        if [ "$answer" == "y" ];
	 then
            rm "$DBs/$db_name/$table_name"  
            if [ -f "$DBs/$db_name/metadata.$table_name" ];
	 then
                rm "$DBs/$db_name/metadata.$table_name"  
            fi
            echo "Table '$table_name' and its metadata Dropped Successfully!"
        else
            echo "Drop Table Cancelled!"
        fi
    else
        echo "Error!! Table '$table_name' Does Not Exist!"
    fi
}


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
