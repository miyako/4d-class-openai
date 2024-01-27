property key : Text
property url : Text

Class constructor
	
	This:C1470.key:=This:C1470._getApiToken()
	This:C1470.url:="https://api.openai.com/v1/chat/completions"
	This:C1470.quantity:=5
	
	$window:=Open form window:C675("DataGenerator")
	DIALOG:C40("DataGenerator"; This:C1470; *)
	
Function onLoad()
	
	Form:C1466.clear().setup().toggleSave()
	
Function onUnload()
	
	//MARK:-
	
Function _getApiToken() : Text
	
	var $folder : 4D:C1709.Folder
	$folder:=Folder:C1567(fk database folder:K87:14)
	
	var $file : 4D:C1709.File
	$file:=OB Class:C1730($folder).new($folder.platformPath; fk platform path:K87:2).parent.file("api.token")
	
	return $file.exists ? $file.getText() : ""
	
Function toggleSave()
	
	If (Form:C1466.data.col.length#0) && (Form:C1466.data.col[0]#Null:C1517) && (OB Keys:C1719(Form:C1466.data.col[0]).length=Form:C1466.sets.length)
		OBJECT SET ENABLED:C1123(*; "save"; True:C214)
	Else 
		OBJECT SET ENABLED:C1123(*; "save"; False:C215)
	End if 
	
	return Form:C1466
	
Function clear()
	
	This:C1470.data:={col: []; sel: Null:C1517; pos: Null:C1517; item: Null:C1517}
	This:C1470.data.col[This:C1470.quantity-1]:=Null:C1517
	
	return Form:C1466
	
Function setup()
	
	//MARK:オブジェクト型ポップアップメニュー
	$sets:=[]
	$sets.push({attributeName: "name"; attributeType: "Text"})
	$sets.push({attributeName: "amountIn"; attributeType: "Number"})
	$sets.push({attributeName: "amountOut"; attributeType: "Number"})
	$sets.push({attributeName: "date"; attributeType: "Date"})
	
	This:C1470.sets:=$sets
	
	$headers:=New object:C1471("Authorization"; "Bearer "+This:C1470.key; "Content-Type"; "application/json")
	
	This:C1470.headers:=$headers
	
	$systemPrompt:="Give me a list of fictional personal information good for a sample database. "
	$systemPrompt+="Text must be Japanese, Number must be integer. "
	$systemPrompt+="Generated values must be separated by the character separator ¶. "
	
	This:C1470.systemPrompt:=$systemPrompt
	
	$messages:=[]
	$messages.push({role: "system"; content: $systemPrompt})
	$messages.push({role: "user"; content: "Generate a list of exactly 5 values for \"name\" of type Text."})
	$messages.push({role: "assistant"; content: "西園寺ハルト¶二階堂ツムギ¶如月ユイト¶皇ミオ¶月城リク"})
	$messages.push({role: "user"; content: "Generate a list of exactly 5 values for \"amountIn\" of type Number."})
	$messages.push({role: "assistant"; content: "3535¶64797¶101246¶119¶4477"})
	$messages.push({role: "user"; content: "Generate a list of exactly 5 values for \"date\" of type Date."})
	$messages.push({role: "assistant"; content: "2022-10-05¶2023-05-02¶2023-12-15¶2022-10-14¶2021-05-23"})
	
	This:C1470.messages:=$messages
	
	This:C1470.model:=New object:C1471
	This:C1470.model.values:=["gpt-4-1106-preview"; "gpt-4"; "gpt-3.5-turbo"]
	This:C1470.model.index:=2
	
	return Form:C1466
	
Function save()
	
	var $e経理 : cs:C1710.経理Entity
	
	For each ($data; Form:C1466.data.col)
		
		$e経理:=ds:C1482.経理.new()
		$e経理.名前:=$data.name
		$e経理.支出:=$data.amountOut
		$e経理.収入:=$data.amountIn
		$e経理.日付:=$data.date
		$e経理.save()
		
	End for each 
	
	Form:C1466.clear().toggleSave()
	
Function postRequest()
	
	Form:C1466.clear().toggleSave()
	
	If (This:C1470.key#"")
		
		For each ($set; This:C1470.sets)
			
			$userPrompt:="Generate a list of exactly "+String:C10(This:C1470.quantity)+" values for \""+$set.attributeName+"\" of type "+$set.attributeType+"."
			
			$data:={}
			$data.model:=Form:C1466.model.currentValue
			$data.messages:=This:C1470.messages.copy()
			$data.messages.push({role: "user"; content: $userPrompt})
			
			If ($attributeType="Date")
				$userPrompt+=". Date format: YYYY-MM-DD"
			End if 
			
			$handler:=cs:C1710.DataGeneratorController.new()
			$handler.method:="POST"
			$handler.headers:=This:C1470.headers
			$handler.body:=$data
			$handler.attributeName:=$set.attributeName
			$handler.attributeType:=$set.attributeType
			
			//MARK:Formのコンテキストでインスタンス化＝Formのコンテキストでコールバック実行）
			$request:=4D:C1709.HTTPRequest.new(This:C1470.url; $handler)
			
		End for each 
		
	End if 