<?php
header('Content-Type: application/json');

$data = json_decode(file_get_contents('php://input'));

$key = $data->key;


echo ' { "status":"success" , "message":"" , "message_count":"1" , "convo_messages": ' . GetMessages() . ' } ';

function GetMessages()
{
	return ' [{
		          "key":"convo-Message-key_600"
		        , "type":"CONVO_MESSAGE"
		        , "parentConvoThreadKey":"Convo-thread-key_1"
		        , "dateCreated":"2013-11-20 19:58:00"
		        , "owner":"a@a.com"
		        , "text":"new message from getNewConvoMessages.php request"
		     },{
		          "key":"convo-Message-key_601"
		        , "type":"CONVO_MESSAGE"
		        , "parentConvoThreadKey":"Convo-thread-key_1"
		        , "dateCreated":"2013-11-20 19:58:00"
		        , "owner":"a@a.com"
		        , "text":""
		        , "imageInfo":{
			          "dateCreated":"2013-09-06 19:19:19"
			        , "extension":"jpg"
			        , "filename":"19AC3138-8EDB-4022-B011-97FA62BB88C3"
			        , "key":"19AC3138-8EDB-4022-B011-97FA62BB88C3"
			        , "owner":"asdf@outlook.com"
			        , "parentConvoMessageKey":"convo-Message-key_601"
			        , "parentProjectKey":""
			        , "type":"IMAGE_INFO"
			    }
		     },{
		          "key":"convo-Message-key_602"
		        , "type":"CONVO_MESSAGE"
		        , "parentConvoThreadKey":"Convo-thread-key_1"
		        , "dateCreated":"2013-11-20 19:58:00"
		        , "owner":"a@a.com"
		        , "text":""
		        , "imageInfo":{
			          "dateCreated":"2013-09-06 19:19:19"
			        , "extension":"jpg"
			        , "filename":"4C5A8FE7-42F6-4301-8882-75E79D0FCFD0"
			        , "key":"4C5A8FE7-42F6-4301-8882-75E79D0FCFD0"
			        , "owner":"asdf@outlook.com"
			        , "parentConvoMessageKey":"convo-Message-key_602"
			        , "parentProjectKey":""
			        , "type":"IMAGE_INFO"
			    }
		     },{
		          "key":"convo-Message-key_603"
		        , "type":"CONVO_MESSAGE"
		        , "parentConvoThreadKey":"Convo-thread-key_1"
		        , "dateCreated":"2013-11-20 19:58:00"
		        , "owner":"a@a.com"
		        , "text":""
		        , "imageInfo":{
			          "dateCreated":"2013-09-06 19:19:19"
			        , "extension":"jpg"
			        , "filename":"64FF5EBE-BC15-4E09-B8BE-2FB44B5216E0"
			        , "key":"64FF5EBE-BC15-4E09-B8BE-2FB44B5216E0"
			        , "owner":"asdf@outlook.com"
			        , "parentConvoMessageKey":"convo-Message-key_603"
			        , "parentProjectKey":""
			        , "type":"IMAGE_INFO"
			    }
		     },{
		          "key":"convo-Message-key_604"
		        , "type":"CONVO_MESSAGE"
		        , "parentConvoThreadKey":"Convo-thread-key_1"
		        , "dateCreated":"2013-11-20 19:58:00"
		        , "owner":"a@a.com"
		        , "text":""
		        , "imageInfo":{
			          "dateCreated":"2013-09-06 19:19:19"
			        , "extension":"jpg"
			        , "filename":"250F34A9-562F-4420-B148-BA221D281B8C"
			        , "key":"250F34A9-562F-4420-B148-BA221D281B8C"
			        , "owner":"asdf@outlook.com"
			        , "parentConvoMessageKey":"convo-Message-key_604"
			        , "parentProjectKey":""
			        , "type":"IMAGE_INFO"
			    }
		     }]
    ';
}

?>