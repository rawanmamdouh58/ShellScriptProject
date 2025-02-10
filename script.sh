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
                 selectFromTable
                 break
                   ;;
            "Delete From Table")
                 deleteFromTable
                 break
                   ;;
            "Update Table")
            	updateTable
            	break
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

    if [ ! -f $table_name ]; 
    then
        echo "Error!! Table '$table_name' Does Not Exist!"
        return
    fi

    columns=$(sed -n '1p' metadata.$table_name)
    datatypes=$(sed -n '2p' metadata.$table_name)
    pk=$(sed -n '3p' metadata.$table_name)

    echo "Columns: $columns"
    echo "Enter Values Separated By Commas: "
    read values

    colArr=($(echo $columns | tr ',' ' '))
    typeArr=($(echo $datatypes | tr ',' ' '))
    valArr=($(echo $values | tr ',' ' '))

    if [ "${#colArr[@]}" -ne "${#valArr[@]}" ]; 
    then
        echo "Error!! Number of values does not match number of columns!"
        return
    fi

    for i in "${!colArr[@]}"; do
        case "${typeArr[$i]}" in
            int)
                if [[ ! "${valArr[$i]}" =~ ^[0-9]+$ ]]; then
                    echo "Error!! Column '${colArr[$i]}' requires an integer!"
                    return
                fi
                ;;
            string)
                if [[ ! "${valArr[$i]}" =~ ^[a-zA-Z0-9]+$ ]]; then
                    echo "Error!! Column '${colArr[$i]}' requires a string!"
                    return
                fi
                ;;
            float)
                if [[ ! "${valArr[$i]}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
                    echo "Error!! Column '${colArr[$i]}' requires a float!"
                    return
                fi
                ;;
            *)
                echo "Error!! Unknown data type for column '${colArr[$i]}'!"
                return
                ;;
        esac
    done

    for i in "${!colArr[@]}"; do
    if [[ "${colArr[$i]}" == "$pk" ]]; then
        pkIndex=$i
        break
    fi
    done

    pkValue="${valArr[$pkIndex]}"

    if cut -d ',' -f "$((pkIndex + 1))" "$table_name" | grep -qx "$pkValue"; 
    then
        echo "Error!! Primary Key '$pk' value '$pkValue' already exists!"
        return
    fi

    echo "$values" >> "$table_name"
    echo "Data Inserted Successfully!"
}
 
updateTable() {
    echo "Enter Table Name You Want To Update: "
    read table_name

    if [[ ! -f "$table_name" ]]; then  
        echo "Error!! Table '$table_name' Does Not Exist!" 
        return 1
    fi

    columns=$(sed -n '1p' "metadata.$table_name")
    datatypes=$(sed -n '2p' "metadata.$table_name")
    pk_column=$(sed -n '3p' "metadata.$table_name")

    colArr=($(echo "$columns" | tr ',' ' '))
    typeArr=($(echo "$datatypes" | tr ',' ' '))

    echo "Columns: $columns"
    echo "Enter the Column Name You Want to Update:"
    read col_name

    colIndex=-1
    for i in "${!colArr[@]}"; do
        if [[ "${colArr[$i]}" == "$col_name" ]]; then
            colIndex=$((i + 1))
            data_type="${typeArr[$i]}"
            break
        fi
    done

    if [[ $colIndex -eq -1 ]]; then
        echo "Error!! Column '$col_name' Not Found."
        return 1
    fi

    echo "Enter the New Value:"
    read new_val

    case "$data_type" in
        int)
            if [[ ! "$new_val" =~ ^[0-9]+$ ]]; then
                echo "Error!! Column '$col_name' Requires an Integer!"
                return 1
            fi
            ;;
        string)
            if [[ ! $new_val =~ ^[a-zA-Z0-9\ ]+$ ]]; then
    		echo "Error!! Column '$col_name' Requires a String!"
   		return 1
	    fi
	    ;;
        float)
            if [[ ! "$new_val" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
                echo "Error!! Column '$col_name' Requires a Float!"
                return 1
            fi
            ;;
        *)
            echo "Error!! Unknown Data Type for Column '$col_name'!"
            return 1
            ;;
    esac

    echo "Enter the Condition to Find the Row to Update (column_name=value):"
    read condition

    condition_col=$(echo "$condition" | cut -d '=' -f 1)
    condition_val=$(echo "$condition" | cut -d '=' -f 2)

    condIndex=-1
    for i in "${!colArr[@]}"; do
        if [[ "${colArr[$i]}" == "$condition_col" ]]; then
            condIndex=$((i + 1))
            break
        fi
    done

    if [[ $condIndex -eq -1 ]]; then
        echo "Error!! Column '$condition_col' Not Found."
        return 1
    fi

    temp_file=$(mktemp)
    updated=0

    awk -F ',' -v col="$colIndex" -v new_val="$new_val" -v cond_col="$condIndex" -v cond_val="$condition_val" '
    BEGIN { OFS="," }
    {
        if (NR == 1) {
            print $0
        } else {
            if ($cond_col == cond_val) {
                $col = new_val
                updated = 1
            }
            print $0
        }
    }
    END {
        if (!updated) {
            print "Warning: No Matching Rows Found!" > "/dev/stderr"
        }
    }' "$table_name" > "$temp_file"

    if grep -q "Warning: No Matching Rows Found!" "$temp_file"; then
        cat "$temp_file"
        rm "$temp_file"
        return 1
    else
        mv "$temp_file" "$table_name"
        echo "Update Successful!"
    fi
}
 
selectFromTable(){
    echo "Enter Table Name You Want To Select From: "
    read table_name

    if [ ! -f "$table_name" ]; then
        echo "Error!! Table '$table_name' Does Not Exist!"
        return
    fi

    columns=$(sed -n '1p' "metadata.$table_name")
    colArr=($(echo "$columns" | tr ',' ' '))

    echo "Columns: $columns"
    echo "1) Select Specific Columns"
    echo "2) Select All Rows"
    echo "3) Select Rows Where a Column Matches a Value"
    read -p "Choose an option (1-3): " choice

    case $choice in
        1)
            echo "Enter Column Names Separated by Commas: "
            read selected_cols

            colIndices=""
            for col in $(echo "$selected_cols" | tr ',' ' '); do
                for i in "${!colArr[@]}"; do
                    if [[ "${colArr[$i]}" == "$col" ]]; then
                    	  if [[ -z "$colIndices" ]]; then
    				colIndices="\$"$((i+1))  
			  else
   				colIndices+=",\$"$((i+1)) 
		    fi
                        break
                    fi
                done
            done

            if [[ -z "$colIndices" ]]; then
                echo "Error!! No valid columns selected!"
                return
            fi

            awk -F ',' "{ print $colIndices }" "$table_name"
            ;;
        2)
            awk -F ',' '{ for (i=1; i<=NF; i++) printf $i "\t"; print "" }' "$table_name"
            ;;
        3)
            echo "Enter Column Name to Filter By: "
            read column_name
            colIndex=-1

            for i in "${!colArr[@]}"; do
                if [[ "${colArr[$i]}" == "$column_name" ]]; then
                    colIndex=$((i + 1))
                    break
                fi
            done

            if [[ $colIndex -eq -1 ]]; then
                echo "Error!! Column '$column_name' Does Not Exist!"
                return
            fi

            echo "Enter Value to Search: "
            read search_value

            awk -F ',' -v col="$colIndex" -v val="$search_value" '$col == val' $table_name
            ;;
        *)
            echo "Invalid Option!"
            ;;
    esac
}

deleteFromTable(){
    echo "Enter Table Name You Want to Delete From: "
    read table_name

    if [ ! -f "$table_name" ]; then
        echo "Error!! Table '$table_name' Does Not Exist!"
        return
    fi

    columns=$(sed -n '1p' metadata.$table_name)
    colArr=($(echo "$columns" | tr ',' ' '))

    echo "Columns: $columns"
    echo "Enter Column Name to Filter Rows for Deletion: "
    read column_name

    colIndex=-1
    for i in "${!colArr[@]}"; do
        if [[ "${colArr[$i]}" == "$column_name" ]]; then
            colIndex=$((i + 1)) 
            break  
        fi
    done

    if [[ $colIndex -eq -1 ]]; then
        echo "Error!! Column '$column_name' Does Not Exist!"
        return
    fi

    echo "Enter Value for $column_name to Delete Rows: "
    read search_value

  
    echo "Are you sure you want to delete rows where '$column_name' = '$search_value'? (y/n)"
    read confirmation
    if [[ "$confirmation" != "y" ]]; then
        echo "Deletion cancelled."
        return
    fi

    temp_file=$(mktemp)  
    awk -F ',' -v col="$colIndex" -v val="$search_value" '
    NR == 1 { print $0 }  
    NR > 1 && $col != val { print $0 }' "$table_name" > "$temp_file"

    mv "$temp_file" "$table_name"  
    echo "Rows matching '$search_value' in column '$column_name' deleted successfully."
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

    if [ -f $table_name ]; 
	then
        echo "Are You Sure You Want To Drop Table '$table_name'? (y/n)"
        read answer
        if [ "$answer" == "y" ];
	 then
            rm $table_name 
            if [ -f metadata.$table_name ];
	 then
                rm metadata.$table_name  
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
