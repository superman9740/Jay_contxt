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
	echo ' { "status":"success" , "message":"" , "items": ' . InnerAnnotationDoc( $key ) . ' } ';
}

function InnerAnnotationDoc( $oKey )
{
	if( $oKey != "FF5FF574-0000-0000-0000-7B51838B7F1F" )
	{
		return '[]';
	}
	else
	{
		return ' [{
		        	  "type":"DRAWING_ANNOTATION"
		        	, "status":"UPDATED"
		        	, "object":{
				        "anchorPoint":{
				             "x":"125"
				            ,"y":"300"
				        }
				        , "color":"4"
				        , "dateCreated":"2013-09-10 01:55:00"
				        , "dateUpdated":"2013-09-10 22:10:00"
				        , "owner":"asdf@outlook.com"
				        , "details":{
				              "dateCreated":"2013-09-10 01:55:00"
				            , "dateUpdated":"2013-09-10 22:10:00"
				            , "key":"3007E211-912A-4BA4-A0AD-07B80E46EB21"
				            , "parentAnnotationKey":"7CC475FF-1E99-4844-9494-82BF17DD3B8F"
				            , "type":"ANNOTATION_DETAILS"
				        }
				        , "drawingType":"2"
				        , "key":"7CC475FF-1E99-4844-9494-82BF17DD3B8F"
				        , "parentAnnotationDocKey":"FF5FF574-0000-0000-0000-7B51838B7F1F"
				        , "size":{
				              "height":"56"
				            , "width":"53"
				        }
				        , "text":""
				        , "type":"DRAWING_ANNOTATION"
					}
		        },{
		        	  "type":"DRAWING_ANNOTATION"
		        	, "status":"CREATED"
		        	, "object":{
				        "anchorPoint":{
				             "x":"49"
				            ,"y":"49"
				        }
				        , "color":"1"
				        , "dateCreated":"2013-09-10 01:55:00"
				        , "dateUpdated":"2013-09-10 22:10:00"
				        , "owner":"asdf@outlook.com"
				        , "details":{
				              "dateCreated":"2013-09-10 01:55:00"
				            , "dateUpdated":"2013-09-10 22:10:00"
				            , "key":"details-key-annot-key-12345"
				            , "parentAnnotationKey":"annot-12345"
				            , "type":"ANNOTATION_DETAILS"
				        }
				        , "drawingType":"1"
				        , "key":"annot-12345"
				        , "parentAnnotationDocKey":"FF5FF574-0000-0000-0000-7B51838B7F1F"
				        , "size":{
				              "height":"30"
				            , "width":"30"
				        }
				        , "text":""
				        , "type":"DRAWING_ANNOTATION"
					}
		        },{
		        	  "type":"DRAWING_ANNOTATION"
		        	, "status":"CREATED"
		        	, "object":{
				        "anchorPoint":{
				             "x":"100"
				            ,"y":"100"
				        }
				        , "color":"2"
				        , "dateCreated":"2013-09-10 01:55:00"
				        , "dateUpdated":"2013-09-10 22:10:00"
				        , "owner":"asdf@outlook.com"
				        , "details":{
				              "dateCreated":"2013-09-10 01:55:00"
				            , "dateUpdated":"2013-09-10 22:10:00"
				            , "key":"details-key-annot-LINE-1"
				            , "parentAnnotationKey":"annot-LINE-1"
				            , "type":"ANNOTATION_DETAILS"
				        }
				        , "drawingType":"3"
				        , "key":"annot-LINE-1"
				        , "parentAnnotationDocKey":"FF5FF574-0000-0000-0000-7B51838B7F1F"
				        , "size":{
				              "height":"50"
				            , "width":"50"
				        }
				        , "text":""
				        , "type":"DRAWING_ANNOTATION"
					}
		        },{
		        	  "type":"DRAWING_ANNOTATION"
		        	, "status":"CREATED"
		        	, "object":{
				        "anchorPoint":{
				             "x":"200"
				            ,"y":"200"
				        }
				        , "color":"3"
				        , "dateCreated":"2013-09-10 01:55:00"
				        , "dateUpdated":"2013-09-10 22:10:00"
				        , "owner":"asdf@outlook.com"
				        , "details":{
				              "dateCreated":"2013-09-10 01:55:00"
				            , "dateUpdated":"2013-09-10 22:10:00"
				            , "key":"details-key-annot-LEADER-1"
				            , "parentAnnotationKey":"annot-LEADER-1"
				            , "type":"ANNOTATION_DETAILS"
				        }
				        , "drawingType":"4"
				        , "key":"annot-LEADER-1"
				        , "parentAnnotationDocKey":"FF5FF574-0000-0000-0000-7B51838B7F1F"
				        , "size":{
				              "height":"-30"
				            , "width":"70"
				        }
				        , "text":""
				        , "type":"DRAWING_ANNOTATION"
					}
		        },{
		        	  "type":"DRAWING_ANNOTATION"
		        	, "status":"CREATED"
		        	, "object":{
				        "anchorPoint":{
				             "x":"10"
				            ,"y":"300"
				        }
				        , "color":"5"
				        , "dateCreated":"2013-09-10 01:55:00"
				        , "dateUpdated":"2013-09-10 22:10:00"
				        , "owner":"asdf@outlook.com"
				        , "details":{
				              "dateCreated":"2013-09-10 01:55:00"
				            , "dateUpdated":"2013-09-10 22:10:00"
				            , "key":"details-key-annot-DIMENSION-1"
				            , "parentAnnotationKey":"annot-DIMENSION-1"
				            , "type":"ANNOTATION_DETAILS"
				        }
				        , "drawingType":"9"
				        , "key":"annot-DIMENSION-1"
				        , "parentAnnotationDocKey":"FF5FF574-0000-0000-0000-7B51838B7F1F"
				        , "size":{
				              "height":"20"
				            , "width":"20"
				        }
				        , "text":""
				        , "type":"DRAWING_ANNOTATION"
					}
		        },{
		        	  "type":"DRAWING_ANNOTATION"
		        	, "status":"CREATED"
		        	, "object":{
				        "anchorPoint":{
				             "x":"220"
				            ,"y":"10"
				        }
				        , "color":"7"
				        , "dateCreated":"2013-09-10 01:55:00"
				        , "dateUpdated":"2013-09-10 22:10:00"
				        , "owner":"asdf@outlook.com"
				        , "details":{
				              "dateCreated":"2013-09-10 01:55:00"
				            , "dateUpdated":"2013-09-10 22:10:00"
				            , "key":"details-key-annot-TEXT-1"
				            , "parentAnnotationKey":"annot-TEXT-1"
				            , "type":"ANNOTATION_DETAILS"
				        }
				        , "drawingType":"7"
				        , "key":"annot-TEXT-1"
				        , "parentAnnotationDocKey":"FF5FF574-0000-0000-0000-7B51838B7F1F"
				        , "size":{
				              "height":"50"
				            , "width":"100"
				        }
				        , "text":"From the Server!"
				        , "fontSize":"23"
				        , "type":"DRAWING_ANNOTATION"
					}
				},{
					  "type":"DRAWING_ANNOTATION"
					, "status":"DELETED"
					, "object":{ "key":"C5DDFC3E-B1A7-408B-A76C-541EEBE05F1F" }
				},{
					  "type":"CONVO_PARTICIPANT"
					, "status":"DELETED"
					, "object":{
						  "participantEmail":"asdf@gmail.com"
						, "convoAnnotationKey":"convo-annotation-1"
					}
				},{
					  "type":"CONVO_PARTICIPANT"
					, "status":"CREATED"
					, "object":{
						  "convoAnnotationKey":"convo-annotation-1"
						, "contxtContact":{
				        	  "key":"contxt-contact-4"
				        	, "type":"CONTXT_CONTACT"
				        	, "email":"test@oh-yeah.com"
				        	, "firstName":"Someone"
				        	, "lastName":"Else"
				        }
					}
				},{
					  "type":"CONVO_MESSAGE"
					, "status":"CREATED"
					, "object":{ 
				          "key":"convo-Message-key_500"
				        , "type":"CONVO_MESSAGE"
				        , "parentConvoThreadKey":"Convo-thread-key_1"
				        , "dateCreated":"2013-11-20 19:58:00"
				        , "owner":"Onely@a.com"
				        , "text":"this is a \"fancy\" NEW message!"
					}
			  }]
	    ';
	}
}

?>