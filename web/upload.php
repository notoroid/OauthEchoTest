<?php

	define( 'APPLICATION_DEFINTION' , '?application_id=com.irimasu.OauthEchoTest' );

	$headers = array();
	
	$resultValue = array();
	if( empty($_SERVER['HTTP_X_AUTH_SERVICE_PROVIDER']) ){
		$resultValue['status'] = 'failure';
		$resultValue['errorCode'] = 1;
		$resultValue['description'] = 'X-Auth-Service-Provider がヘッダに含まれていません。';
	}else if( empty($_SERVER['HTTP_X_VERIFY_CREDENTIALS_AUTHORIZATION']) ){
		$resultValue['status'] = 'failure';
		$resultValue['errorCode'] = 2;
		$resultValue['description'] = 'X-Verify-Credentials-Authorization がヘッダに含まれていません。';
	}else if( $_SERVER['HTTP_X_AUTH_SERVICE_PROVIDER'] != 'https://api.twitter.com/1/account/verify_credentials.json' . APPLICATION_DEFINTION ){
		$resultValue['status'] = 'failure';
		$resultValue['errorCode'] = 4;
		$resultValue['description'] = 'X-Auth-Service-Provider の値が不正です。';
	}else{
		$HTTPXAuthServiceProvider = $_SERVER['HTTP_X_AUTH_SERVICE_PROVIDER'];
		$HTTPXVerifyCredentialsAuthorization = $_SERVER['HTTP_X_VERIFY_CREDENTIALS_AUTHORIZATION'];

		// ヘッダ情報を付加して情報を取得する
		$context = stream_context_create(array('http' => array(
			 'method' => 'GET'
		     ,'header'  => 'Authorization: ' . $HTTPXVerifyCredentialsAuthorization . "\r\n"
      		)
		));
		

		error_reporting(0);
		
		if( ($data = file_get_contents($HTTPXAuthServiceProvider , false, $context)) != FALSE ){
			error_reporting(1);
		
			$resultValue['status'] = 'succeeded';
			$resultValue['errorCode'] = 0;
//			$resultValue['result'] = json_decode($data);
		}else{
			error_reporting(1);
		
			list($version,$status_code,$msg) = explode(' ',$http_response_header[0], 3);
			
			$resultValue['status'] = 'failure';
			
			switch($status_code) {
			case 401:
				$resultValue['errorCode'] = 5;
				$resultValue['description'] = $status_code . ' Unauthorized';
				$resultValue['http_response_header'] = array(    'version' => $version
																,'status' => $status_code
																,'message' => $msg );
			    break;
			case 404:
				$resultValue['errorCode'] = 6;
				$resultValue['description'] = $status_code . 'Not found.';
				$resultValue['http_response_header'] = array(    'version' => $version
																,'status' => $status_code
																,'message' => $msg );
			    break;
			default:
				$resultValue['errorCode'] = 7;
				$resultValue['description'] = $status_code . 'Unknown error.';
				$resultValue['http_response_header'] = array(    'version' => $version
																,'status' => $status_code
																,'message' => $msg );
			    break;
			}
		}
	}

	if( !headers_sent()	){
		header ("Content-Type: text/html; charset=UTF-8");
	}
	echo json_encode($resultValue);
?>