<?php
header('Content-Type: application/json');

$data = json_decode(file_get_contents('php://input'));

$request_type = $data->request_type;


echo ' { "status":"success" , "message":"" , "annotation_docs":[ ' . GetAnnotationDoc0() . ' , ' . GetAnnotationDoc1() . ' , ' . GetAnnotationDoc2() . ' ] } ';
//echo ' { "status":"error" , "message":"Unknown request type `' . $request_type . '`." } ';


function GetAnnotationDoc0()
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
        , "owner":"chad.morris@outlook.com"
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
    },{
        "anchorPoint":{
             "x":"150.5"
            ,"y":"250.5"
        }
        , "dateCreated":"2013-09-10 01:55:00"
        , "dateUpdated":"2013-09-10 22:10:00"
        , "owner":"chad.morris@outlook.com"
        , "key":"7CC475FF-AAAA-AAAA-9494-82BF17DD3B8F"
        , "parentAnnotationDocKey":"FF5FF574-0000-0000-0000-7B51838B7F1F"
        , "type":"IMAGE_ANNOTATION"
    },{
        "anchorPoint":{
             "x":"155.5"
            ,"y":"250.5"
        }
        , "dateCreated":"2013-09-10 01:55:00"
        , "dateUpdated":"2013-09-10 22:10:00"
        , "owner":"chad.morris@outlook.com"
        , "key":"7CC475FF-EEEE-EEEE-9494-82BF17DD3B8F"
        , "parentAnnotationDocKey":"FF5FF574-0000-0000-0000-7B51838B7F1F"
        , "type":"IMAGE_ANNOTATION"
    },{
        "anchorPoint":{
             "x":"300.5"
            ,"y":"100.5"
        }
        , "dateCreated":"2013-09-10 01:55:00"
        , "dateUpdated":"2013-09-10 22:10:00"
        , "owner":"a@a.com"
        , "key":"convo-annotation-1"
        , "parentAnnotationDocKey":"FF5FF574-0000-0000-0000-7B51838B7F1F"
        , "type":"CONVO_ANNOTATION"
    }]
    , "imageInfo":{
          "dateCreated":"2013-09-06 19:19:19"
        , "extension":"jpg"
        , "filename":"2E70A413-F18A-4FB4-B0C4-FB9FB06DEAEE"
        , "key":"2E70A413-F18A-4FB4-B0C4-FB9FB06DEAEE"
        , "owner":"chad.morris@outlook.com"
        , "parentAnnotationDocKey":"FF5FF574-0000-0000-0000-7B51838B7F1F"
        , "parentConvoMessageKey":""
        , "parentProjectKey":""
        , "type":"IMAGE_INFO"
    }
    , "key":"FF5FF574-0000-0000-0000-7B51838B7F1F"
    , "type":"ANNOTATION_DOC"
}';

}

function GetAnnotationDoc1()
{
	return ' {
    "annotations":[{
        "anchorPoint":{
             "x":"154"
            ,"y":"200"
        }
        , "color":"3"
        , "dateCreated":"2013-09-10 01:55:00"
        , "dateUpdated":"2013-09-10 22:10:00"
        , "owner":"chad.morris@outlook.com"
        , "drawingType":"2"
        , "key":"drawing-annotation---111"
        , "parentAnnotationDocKey":"12312312-0000-0000-0000-7B51838B7F1F"
        , "size":{
              "height":"56"
            , "width":"53"
        }
        , "text":""
        , "type":"DRAWING_ANNOTATION"
    },{
        "anchorPoint":{
             "x":"100.5"
            ,"y":"100.5"
        }
        , "dateCreated":"2013-09-10 01:55:00"
        , "dateUpdated":"2013-09-10 22:10:00"
        , "owner":"a@a.com"
        , "key":"convo-annotation-111"
        , "parentAnnotationDocKey":"12312312-0000-0000-0000-7B51838B7F1F"
        , "type":"CONVO_ANNOTATION"
    }]
    , "imageInfo":{
          "dateCreated":"2013-09-15 19:19:19"
        , "extension":"jpg"
        , "filename":"CC3099DE-7176-416C-A3AE-072022982686"
        , "key":"CC3099DE-7176-416C-A3AE-072022982686"
        , "owner":"chad.morris@outlook.com"
        , "parentAnnotationDocKey":"12312312-0000-0000-0000-7B51838B7F1F"
        , "parentConvoMessageKey":""
        , "parentProjectKey":""
        , "type":"IMAGE_INFO"
    }
    , "key":"12312312-0000-0000-0000-7B51838B7F1F"
    , "type":"ANNOTATION_DOC"
}';
}

function GetAnnotationDoc2()
{
	return ' {
    "annotations":[{
        "anchorPoint":{
             "x":"150"
            ,"y":"200"
        }
        , "color":"3"
        , "dateCreated":"2013-09-10 01:55:00"
        , "dateUpdated":"2013-09-10 22:10:00"
        , "owner":"chad.morris@outlook.com"
        , "drawingType":"5"
        , "key":"drawing-annotation---222"
        , "parentAnnotationDocKey":"22222222-0000-0000-0000-7B51838B7F1F"
        , "size":{
              "height":"100"
            , "width":"100"
        }
        , "customPoints":[
        	  { "x":"150" , "y":"200" } 
        	, { "x":"180" , "y":"200" } 
        	, { "x":"150" , "y":"250" } 
        	, { "x":"180" , "y":"250" } 
        	, { "x":"150" , "y":"200" } 
        ]
        , "text":""
        , "type":"DRAWING_ANNOTATION"
    },{
        "anchorPoint":{
             "x":"100.5"
            ,"y":"100.5"
        }
        , "dateCreated":"2013-09-10 01:55:00"
        , "dateUpdated":"2013-09-10 22:10:00"
        , "owner":"a@a.com"
        , "key":"convo-annotation-222"
        , "parentAnnotationDocKey":"22222222-0000-0000-0000-7B51838B7F1F"
        , "type":"CONVO_ANNOTATION"
    }]
    , "imageInfo":{
          "dateCreated":"2013-10-01 19:19:19"
        , "extension":"jpg"
        , "filename":"A42E793A-84A7-4AC4-A85E-B3147F80DFDD"
        , "key":"A42E793A-84A7-4AC4-A85E-B3147F80DFDD"
        , "owner":"chad.morris@outlook.com"
        , "parentAnnotationDocKey":"22222222-0000-0000-0000-7B51838B7F1F"
        , "parentConvoMessageKey":""
        , "parentProjectKey":""
        , "type":"IMAGE_INFO"
    }
    , "key":"22222222-0000-0000-0000-7B51838B7F1F"
    , "type":"ANNOTATION_DOC"
}';
}


?>