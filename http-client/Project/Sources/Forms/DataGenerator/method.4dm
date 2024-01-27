$event:=FORM Event:C1606

Case of 
	: ($event.code=On Load:K2:1)
		
		Form:C1466.onLoad()
		
	: ($event.code=On Unload:K2:2)
		
		Form:C1466.onUnload()
		
End case 