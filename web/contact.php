<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="BaconBar Mac App">
        <meta name="author" content="Thomas Buck">
        <title>BaconBar - Contact Developer</title>
        <link rel="shortcut icon" href="favicon.png">
        <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.0.3/css/bootstrap.min.css">
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <div id="out" class="container">
            <a name="top"></a>
            <div class="header">
                <ul class="nav nav-pills pull-right">
                    <li><a href="index.html">BaconBar</a></li>
                    <li class="active"><a href="#">Contact</a></li>
                </ul>
                <h1>BaconBar</h1>
            </div>
<?php
if ($_SERVER['REQUEST_METHOD'] == "POST") {
    $email = $_POST['mail'];
    $subject = $_POST['subject'];
    $message = $_POST['message'];
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
?>
                <div class="alert alert-warning">Please enter a valid E-Mail Address!</div>
<?php
    } else {
        $message = wordwrap($message, 70);
        $mailheader = "From: $email\r\nReply-To: $email\r\n";
        if (mail("xythobuz@xythobuz.de", $subject, $message, $mailheader)) {
?>
            <div class="alert alert-success">Your message has been sent!</div>
<?php
        } else {
?>
            <div class="alert alert-danger">Your message couldn't be sent! Sorry :(</div>
<?php
        }
    }
?>
                <div class="alert alert-info"><a href="javascript:history.back()">Go Back</a></div>
<?php
} else {
?>
            <p>
                You can contact me using my personal E-Mail Address
                <a href='&#109;ailto&#58;xyt&#104;o&#98;uz&#64;xy&#116;%&#54;8ob&#117;%7A&#46;&#100;e'>
                    &lt;xy&#116;hobuz&#64;xyt&#104;obuz&#46;de&gt;
                </a>
                or with the following Contact Form.
            </p>

            <form action="contact.php" method="POST">
                <fieldset>
                    <legend>
                        Contact BaconBar Developer
                    </legend>
                    <label>
                        E-Mail Address
                        <input type="email" name="mail" class="form-control" placeholder="john.doe@example.com" required>
                    </label>
                    <br>
                    <label>
                        Subject
                        <input type="text" name="subject" class="form-control" required>
                    </label>
                    <br>
                    <label>
                        Message
                        <textarea name="message" class="form-control" rows="10" required></textarea>
                    </label>
                    <br>
                    <label>
                        <input type="submit" value="Send mail!" class="btn btn-success pull-right butt">
                    </label>
                </fieldset>
            </form>
<?php
}
?>
            <div class="footer">
                <span>&copy; 2013 <a href="//xythobuz.de">Thomas Buck</a></span>
                <span class="pull-right">Made with <a href="//getbootstrap.com">Bootstrap</a></span>
            </div>
        </div>
    <img src="//xythobuz.de/stats/count.php?img" alt="Analytics">
    <script src="//code.jquery.com/jquery-1.10.1.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.0.3/js/bootstrap.min.js"></script>
    </body>
</html>
