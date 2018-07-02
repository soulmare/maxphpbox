<?php

  error_reporting(E_ALL);
  ini_set("display_errors", 1);


  //if "email" variable is filled out, send email
  if (isset($_REQUEST['email']))  {
  
    //Email information
    $admin_email = "someone@example.com";
    $email = $_REQUEST['email'];
    $subject = $_REQUEST['subject'];
    $body = $_REQUEST['body'];
    
    //send email
    $result = mail($admin_email, "$subject", $body, "From:" . $email);
    
    //Email response
    if ($result) {
      echo "<b style='color:blue'>OK mail sent</b>";
    } else {
      echo "<b style='color:red'>Error</b><br>";
      var_export(error_get_last());
    }
  }
    
?>

 <form method="post">

  Email: <input name="email" type="text" value="<?php echo htmlspecialchars(@$_REQUEST['email'])?>" />

  Subject: <input name="subject" type="text" value="<?php echo htmlspecialchars(@$_REQUEST['subject'])?>" />

  Message:

  <textarea name="body" rows="15" cols="40"><?php echo htmlspecialchars(@$_REQUEST['body'])?></textarea>

  <input type="submit" value="Submit" />
  </form>
  
  <br/>
  
  <iframe src="http://vagrant:8025/" style="margin:100px;width:800px;height:400px" />