<!DOCTYPE html>
<html>

<head>
    <title>Insert Page page</title>
</head>

<body>
    <center>
        <?php
        include('db.php')
        // Check connection
        if (!$conn) {
          echo "Failed to connect to MySQL: " . $mysqli -> connect_error;
          exit();
        }
        
        // Taking all 3 values from the form data(input)
        $first_name =  $_REQUEST['first_name'];
        $last_name = $_REQUEST['last_name'];
        $email = $_REQUEST['email'];
        
        // Performing insert query execution
        $sql = "INSERT INTO test  VALUES ('$first_name', 
            '$last_name','$email')";
        
        if(mysqli_query($conn, $sql)){
            echo "<h3>data stored in a database successfully." 
                . " Please refresh the main page to see" 
                . " to view the updated data</h3>"; 

            echo nl2br("\n$first_name\n $last_name\n "
                . "$email");
        } else{
            echo "ERROR: $sql. " 
                . mysqli_error($conn);
        }
        
        // Close connection
        mysqli_close($conn);
        ?>
    </center>
</body>

</html>