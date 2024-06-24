<!DOCTYPE html>
<html>
<head>

	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Hello World!</title>
		<?php
			// DB Connection
		 $servername = "<<Enter RDS endpoint output here>>";
         $username = "root";
         $password = "empty";
         $databasename = "placeholder";
         $conn = mysqli_connect($servername, $username, $password, $databasename);
        $query = "SELECT * FROM test";
        ?>
</head>
<body>
<h1>Hello World!</h1>
<p>You're seeing this as a result of a working Terraform assisted AWS Deployment, on one of 3 ALBs to an EC2 cluster of 2 scaling to 4 if required, this has been Docker containerise and picked up by the EC2 Instance serving you right now!</p>

<p>Here is my latest CV</p>
<a id="cv" href="files/curtismahadevan24062024.pdf" download>Click here to download
<img src="files/curtismahadevan24062024scrnshot.png">
</a>

<form action="insert.php" method="post">
            
<p>
               <label for="firstName">First Name:</label>
               <input type="text" name="first_name" id="firstName">
            </p>
<p>
               <label for="lastName">Last Name:</label>
               <input type="text" name="last_name" id="lastName">
            </p>
<p>
               <label for="emailAddress">Email Address:</label>
               <input type="text" name="email" id="emailAddress">
            </p>

            <input type="submit" value="Submit">
         </form>

<div>
	<p>Previously Entered Data:</p>
	<table>
		<tr>
			<th>First Name</th>
			<th>Last Name</th>
			<th>Email Address</th>
		</tr>
		<?php
		if($conn === true){
			    while ($row = $result->fetch_assoc()) 
			    {
			        $fname = $row["col1"];
			        $sname = $row["col2"];
			        $email = $row["col3"];
			        echo '<tr> 
			                  <td>'.$fname.'</td>
			                  <td>'.$sname.'</td>
			                  <td>'.$email.'</td>
			              </tr>';
			    }
    		}
    		else
    		{
    			echo '<tr>
    					<td>No Entries Yet</td>
    					<td>n/a</td>
    					<td>n/a</td>
    				</tr>';
    		}
		?>
	</table>
</div>
<p>Whilst you're here take a look at some of my favourite foods</p>

<h2>Chicken Tikka Massala</h2>
<p>Despite common misconception this dish was infact created in the UK, which most people would believe it was Indian. Much like me!</p>

<h2>Curtis' Bolognese</h2>
<p>Most people leave out the Sofrito/Mirepoix</p>

<h2>Sourdough</h2>
<p>Precision, Patience and time is key here.</p>

<h2>Croissant</h2>
<p>Buttery and best enjoyed fresh from the oven.</p>

<h3>Database Form</h3>
<p>To test push and pull RDS database information. <b>Important please enter false data, as this will be displayed publicly!</b></p>
</body>
</html>