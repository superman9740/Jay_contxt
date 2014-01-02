<?php
header('Content-Type: application/json');

/* @TODO: VALIDATE USER CREDS */


$allowedExts = array("gif", "jpeg", "jpg", "png");
$temp = explode(".", $_FILES["image"]["name"]);
$extension = end($temp);

$upload_dir = "uploads/";

if ($_FILES["image"]["error"] > 0)
{
	echo '{ "status":"error" , "message":"' . $_FILES["image"]["error"] . '" }';
}
else
{
	if (file_exists($upload_dir . $_FILES["image"]["name"]))
	{
		echo '{ "status":"error" , "message":"' . $_FILES["image"]["name"] . ' already exists." }';
	}
	else
	{
		if( move_uploaded_file( $_FILES["image"]["tmp_name"] , $upload_dir . $_FILES["image"]["name"] ) )
			echo '{ "status":"success" , "message":"Image uploaded successfully." }';
		else
			echo '{ "status":"error" , "message":"Image move failed. Name: ' . $_FILES["image"]["name"] . ' .. Type: ' . $_FILES["files"]["type"] . '" }';
	}
}

//Alternative Image Saving Using cURL seeing as allow_url_fopen is disabled - bummer
function save_image($img, $fullpath)
{
	$ch = curl_init($img);
	curl_setopt($ch, CURLOPT_HEADER, 0);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($ch, CURLOPT_BINARYTRANSFER, 1);
	$rawdata=curl_exec($ch);
	curl_close($ch);

	if
	( curl_errno($ch) )
	{
		return '{ "status":"error" , "message":"An error occurred trying to save the image." }';
	}
	else
	{
		if
		(file_exists($fullpath))
		{
			unlink($fullpath);
		}
		$fp = fopen($fullpath, 'x');
		fwrite($fp, $rawdata);
		fclose($fp);

		return '{ "status":"success" , "message":"Image uploaded successfully." }';
	}
}


/* EXAMPLE USING CURL */
//$img = "http://www.edmondscommerce.co.uk/wp-content/themes/redesign/images/logo.png";
//$path = "./uploads/logo.png";
//echo save_image($img, $upload_path);

?>