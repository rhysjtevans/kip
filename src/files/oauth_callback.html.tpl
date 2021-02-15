<html>
<head>
  <title>Capturing OAuth token</title>
  <script>
  	access_token = null;
	var results = new RegExp('[\?&#]id_token=([^&#]*)').exec(location.href);
	jwtDisplay = null;
	if(results) {
			access_token = results[1];
			console.log('id_token:'+access_token);
			window.location.replace("${OAUTH_CALLBACK_URI}?id_token="+access_token);
	} else {
		alert('cannot find id_token!');
	}
  </script>
</head>
  <h1>Please wait...</h1>
  
</body>
</html>