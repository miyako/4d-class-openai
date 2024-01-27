Class constructor
	
Function onData($request : 4D:C1709.HTTPRequest; $event : cs:C1710.HTTPRequestEvent)
	
	Form:C1466.responseDataSize:=$event.data.size
	
	$headers:=$request.response.headers
	Form:C1466.remainingTokens:=$headers["x-ratelimit-remaining-tokens"]
	Form:C1466.remainingRequsts:=$headers["x-ratelimit-remaining-requests"]
	Form:C1466.processingTime:=$headers["openai-processing-ms"]
	Form:C1466.AIModel:=$headers["openai-model"]
	Form:C1466.AIVersion:=$headers["openai-version"]
	
Function onError($request : 4D:C1709.HTTPRequest; $event : cs:C1710.HTTPRequestEvent)
	
Function onHeaders($request : 4D:C1709.HTTPRequest; $event : cs:C1710.HTTPRequestEvent)
	
Function onResponse($request : 4D:C1709.HTTPRequest; $event : cs:C1710.HTTPRequestEvent)
	
	var $body : Object
	$body:=$request.response.body
	
	Case of 
		: ($body.object="chat.completion")
			
			$id:=$body.id
			$created:=$body.created
			$model:=$body.model
			$choices:=$body.choices
			
			$completion_tokens:=$body.usage.completion_tokens
			$prompt_tokenss:=$body.usage.prompt_tokens
			$total_tokens:=$body.usage.total_tokens
			
			For each ($choice; $choices)
				$message:=$choice.message
				$content:=$message.content
				$role:=$message.role
				If ($role="assistant")
					$values:=Split string:C1554($content; "¶")
					$col:=Form:C1466.data.col
					If ($col.length#0)
						For ($i; 0; $col.length-1)
							If ($col[$i]=Null:C1517)
								$col[$i]:={}
							End if 
							Case of 
								: (This:C1470.attributeType="Date")
									$col[$i][This:C1470.attributeName]:=$values.length>$i ? Date:C102($values[$i]) : Null:C1517
								: (This:C1470.attributeType="Number")
									$col[$i][This:C1470.attributeName]:=$values.length>$i ? Num:C11($values[$i]) : Null:C1517
								Else 
									$col[$i][This:C1470.attributeName]:=$values.length>$i ? String:C10($values[$i]) : Null:C1517
							End case 
						End for 
						
					End if 
				End if 
			End for each 
			
			Form:C1466.toggleSave()
			
			Form:C1466.data.col:=Form:C1466.data.col
			
	End case 
	
Function onTerminate($request : 4D:C1709.HTTPRequest; $event : cs:C1710.HTTPRequestEvent)
	