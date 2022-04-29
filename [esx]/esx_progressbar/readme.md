## Use

* true = freeze player, turn it to false if u dont want it to freeze player 
  
* Without Animation
  
```lua
  ESX.Progressbar("Text Here", 3000, true ,{animation = {},onFinish = function() print("Finish") end})
```

* With Animation 
  
```lua
* ESX.Progressbar("Text Here", 3000, true ,{animation ={type = "anim" ,dict = animdicthere , lib = animnamehere },onFinish = function() print("Finish") end})
```