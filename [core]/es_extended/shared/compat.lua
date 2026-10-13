--All shared functions outsourced from the Core to the lib will be stored here for compatability, e.g:

ESX.Table = {}
ESX.Math = {}

ESX.SetTimeout = xLib.timeout.setTimeout
ESX.ClearTimeout = xLib.timeout.clearTimeout
ESX.Await = xLib.waitFor
ESX.Table.SizeOf = xLib.table.sizeOf
ESX.Table.Set = xLib.table.set
ESX.Table.IndexOf = xLib.table.indexOf
ESX.Table.LastIndexOf = xLib.table.lastIndexOf
ESX.Table.Find = xLib.table.find
ESX.Table.FindIndex = xLib.table.findIndex
ESX.Table.Filter = xLib.table.filter
ESX.Table.Map = xLib.table.map
ESX.Table.Reverse = xLib.table.reverse
ESX.Table.Clone = xLib.table.clone
ESX.Table.Concat = xLib.table.concat
ESX.Table.Join = xLib.table.join
ESX.Table.TableContains = xLib.table.contains
ESX.Table.Sort = xLib.table.sort
ESX.Table.ToArray = xLib.table.toArray
ESX.Table.Wipe = xLib.table.wipe

ESX.Math.Round = xLib.math.Round
ESX.Math.GroupDigits = xLib.math.GroupDigits
ESX.Math.Trim = xLib.math.Trim
ESX.Math.Random = xLib.math.Random
ESX.Math.GetHeadingFromCoords = xLib.math.GetHeadingFromCoords
