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
	echo ' { "status":"success" , "message":"" , "annotation_doc": ' . InnerAnnotationDoc( $key ) . ' } ';
}

function InnerAnnotationDoc( $oKey )
{
	if( $oKey == "7CC475FF-AAAA-AAAA-9494-82BF17DD3B8F" )
	{
		return ' {
	        	"annotations":[{
			        "anchorPoint":{
			             "x":"154"
			            ,"y":"20"
			        }
			        , "color":"2"
			        , "dateCreated":"2013-09-10 01:55:00"
			        , "dateUpdated":"2013-09-10 22:10:00"
			        , "owner":"asdf@outlook.com"
			        , "details":{
			              "dateCreated":"2013-09-10 01:55:00"
			            , "dateUpdated":"2013-09-10 22:10:00"
			            , "key":"3007E211-BBBB-BBBB-A0AD-07B80E46EB21"
			            , "parentAnnotationKey":"DDDDDDDD-DDDD-4844-9494-82BF17DD3B8F"
			            , "type":"ANNOTATION_DETAILS"
			        }
			        , "drawingType":"2"
			        , "key":"DDDDDDDD-DDDD-4844-9494-82BF17DD3B8F"
			        , "parentAnnotationDocKey":"FF5FF574-1234-1234-1234-1234838B7F1F"
			        , "size":{
			              "height":"56"
			            , "width":"53"
			        }
			        , "text":""
			        , "type":"DRAWING_ANNOTATION"
	        	}]
	        	, "imageInfo":{
			          "dateCreated":"2013-09-06 19:19:19"
			        , "extension":"jpg"
			        , "filename":"6F906ABF-2C09-449E-AEC2-4C89869D74B9"
			        , "key":"6F906ABF-2C09-449E-AEC2-4C89869D74B9"
			        , "owner":"asdf@outlook.com"
			        , "parentAnnotationDocKey":"FF5FF574-1234-1234-1234-1234838B7F1F"
			        , "parentConvoMessageKey":""
			        , "parentProjectKey":""
			        , "type":"IMAGE_INFO"
			    }
			    , "parentAnnotationKey":"7CC475FF-AAAA-AAAA-9494-82BF17DD3B8F"
			    , "key":"FF5FF574-1234-1234-1234-1234838B7F1F"
			    , "type":"ANNOTATION_DOC"
	        }
	    ';
	}
	else if( $oKey == "7CC475FF-EEEE-EEEE-9494-82BF17DD3B8F" )
	{
		return ' {
	        	"annotations":[{
			        "anchorPoint":{
			             "x":"154"
			            ,"y":"20"
			        }
			        , "color":"3"
			        , "dateCreated":"2013-09-10 01:55:00"
			        , "dateUpdated":"2013-09-10 22:10:00"
			        , "owner":"asdf@outlook.com"
			        , "details":{
			              "dateCreated":"2013-09-10 01:55:00"
			            , "dateUpdated":"2013-09-10 22:10:00"
			            , "key":"3007E211-CCCC-CCCC-A0AD-07B80E46EB21"
			            , "parentAnnotationKey":"EEEEEEEE-EEEE-4844-9494-82BF17DD3B8F"
			            , "type":"ANNOTATION_DETAILS"
			        }
			        , "drawingType":"2"
			        , "key":"EEEEEEEE-EEEE-4844-9494-82BF17DD3B8F"
			        , "parentAnnotationDocKey":"FF5FF574-7777-7777-7777-1234838B7F1F"
			        , "size":{
			              "height":"56"
			            , "width":"53"
			        }
			        , "text":""
			        , "type":"DRAWING_ANNOTATION"
	        	}]
	        	, "imageInfo":{
			          "dateCreated":"2013-09-06 19:19:19"
			        , "extension":"jpg"
			        , "filename":"BB57D48A-1B64-47BE-B1DB-A637F9DDE326"
			        , "key":"BB57D48A-1B64-47BE-B1DB-A637F9DDE326"
			        , "owner":"asdf@outlook.com"
			        , "parentAnnotationDocKey":"FF5FF574-7777-7777-7777-1234838B7F1F"
			        , "parentConvoMessageKey":""
			        , "parentProjectKey":""
			        , "type":"IMAGE_INFO"
			    }
			    , "parentAnnotationKey":"7CC475FF-EEEE-EEEE-9494-82BF17DD3B8F"
			    , "key":"FF5FF574-7777-7777-7777-1234838B7F1F"
			    , "type":"ANNOTATION_DOC"
	        }
	    ';
	}
}

?>