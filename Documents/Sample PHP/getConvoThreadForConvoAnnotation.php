<?php
header('Content-Type: application/json');

$data = json_decode(file_get_contents('php://input'));

$key = $data->key;


if( $key == null || $key == "" )
{
	echo ' { "status":"error" , "message":"Unknown request type `' . $request_type . '`." } ';
}
else
{
	echo ' { "status":"success" , "message":"" , "convo_thread": ' . ConvoThread( $key ) . ' } ';
}

function ConvoThread( $parentAnnotationKey )
{
//	if( $oKey == "" )
//	{
		return ' {
			      "parentAnnotationKey":"' . $parentAnnotationKey . '"
			    , "key":"Convo-thread-key_1"
			    , "type":"CONVO_THREAD"
		        , "dateCreated":"2013-09-10 01:55:00"
		        , "owner":"a@a.com"
		        , "details":""
		        , "title":""
		        , "participants":[{
		        	  "key":"contxt-contact-1"
		        	, "type":"CONTXT_CONTACT"
		        	, "email":"a@a.com"
		        	, "firstName":"One"
		        	, "lastName":"Person"
		        },{
		        	  "key":"contxt-contact-2"
		        	, "type":"CONTXT_CONTACT"
		        	, "email":"asdf@gmail.com"
		        	, "firstName":"Two"
		        	, "lastName":"Person"
		        },{
		        	  "key":"contxt-contact-3"
		        	, "type":"CONTXT_CONTACT"
		        	, "email":"blah@a.com"
		        	, "firstName":"Three"
		        	, "lastName":"Person"
		        }]
	        	, "convo_messages":[{
			          "key":"convo-Message-key_1"
			        , "type":"CONVO_MESSAGE"
			        , "parentConvoThreadKey":"Convo-thread-key_1"
			        , "dateCreated":"2013-09-10 01:55:00"
			        , "owner":"a@a.com"
			        , "text":"this is the first message"
	        	},{
			          "key":"convo-Message-key_2"
			        , "type":"CONVO_MESSAGE"
			        , "parentConvoThreadKey":"Convo-thread-key_1"
			        , "dateCreated":"2013-09-10 01:58:00"
			        , "owner":"a@a.com"
			        , "text":"this is the second message"
	        	},{
			          "key":"convo-Message-key_2.1"
			        , "type":"CONVO_MESSAGE"
			        , "parentConvoThreadKey":"Convo-thread-key_1"
			        , "dateCreated":"2013-09-10 02:07:36"
			        , "owner":"a@a.com"
			        , "imageInfo":{
				          "dateCreated":"2013-09-06 19:19:19"
				        , "extension":"jpg"
				        , "filename":"BAE8C6BE-C410-4B36-B5B1-207DF74F9F16"
				        , "key":"BAE8C6BE-C410-4B36-B5B1-207DF74F9F16"
				        , "owner":"asdf@outlook.com"
				        , "parentConvoMessageKey":"convo-Message-key_2.1"
				        , "parentProjectKey":""
				        , "type":"IMAGE_INFO"
				    }
	        	},{
			          "key":"convo-Message-key_3"
			        , "type":"CONVO_MESSAGE"
			        , "parentConvoThreadKey":"Convo-thread-key_1"
			        , "dateCreated":"2013-09-10 02:00:00"
			        , "owner":"asdf@gmail.com"
			        , "text":"this should come from someone else"
	        	},{
			          "key":"convo-Message-key_4"
			        , "type":"CONVO_MESSAGE"
			        , "parentConvoThreadKey":"Convo-thread-key_1"
			        , "dateCreated":"2013-09-10 02:01:43"
			        , "owner":"a@a.com"
			        , "text":"yep, it did"
	        	},{
			          "key":"convo-Message-key_5"
			        , "type":"CONVO_MESSAGE"
			        , "parentConvoThreadKey":"Convo-thread-key_1"
			        , "dateCreated":"2013-09-10 02:05:11"
			        , "owner":"asdf@gmail.com"
			        , "text":"show me a pic"
	        	},{
			          "key":"convo-Message-key_6"
			        , "type":"CONVO_MESSAGE"
			        , "parentConvoThreadKey":"Convo-thread-key_1"
			        , "dateCreated":"2013-09-10 02:07:23"
			        , "owner":"a@a.com"
			        , "text":"ok, here ya go..."
	        	},{
			          "key":"convo-Message-key_7"
			        , "type":"CONVO_MESSAGE"
			        , "parentConvoThreadKey":"Convo-thread-key_1"
			        , "dateCreated":"2013-09-10 02:07:36"
			        , "owner":"a@a.com"
			        , "imageInfo":{
				          "dateCreated":"2013-09-06 19:19:19"
				        , "extension":"jpg"
				        , "filename":"ECF05DE3-D055-4E0E-B9D2-65947EAC6877"
				        , "key":"ECF05DE3-D055-4E0E-B9D2-65947EAC6877"
				        , "owner":"asdf@outlook.com"
				        , "parentConvoMessageKey":"convo-Message-key_7"
				        , "parentProjectKey":""
				        , "type":"IMAGE_INFO"
				    }
	        	},{
			          "key":"convo-Message-key_8"
			        , "type":"CONVO_MESSAGE"
			        , "parentConvoThreadKey":"Convo-thread-key_1"
			        , "dateCreated":"2013-09-10 02:12:12"
			        , "owner":"asdf@gmail.com"
			        , "imageInfo":{
				          "dateCreated":"2013-09-06 19:19:19"
				        , "extension":"jpg"
				        , "filename":"E415D70C-745A-4CB9-999E-01736A9CCFCE"
				        , "key":"E415D70C-745A-4CB9-999E-01736A9CCFCE"
				        , "owner":"asdf@outlook.com"
				        , "parentConvoMessageKey":"convo-Message-key_8"
				        , "parentProjectKey":""
				        , "type":"IMAGE_INFO"
				    }
	        	}]
	        }
	    ';
//	}
}

?>