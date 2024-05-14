if not mods["FluidWagonColorMask"] then
   return
end

local vanilla_fluid_wagon_layers = data.raw["fluid-wagon"]["fluid-wagon"]["pictures"]["layers"]
local vanilla_fluid_wagon_color = data.raw["fluid-wagon"]["fluid-wagon"]["color"]
local fluid_wagon_mask = {}

if vanilla_fluid_wagon_layers then
   for _, layer in pairs(vanilla_fluid_wagon_layers) do
      local flags = layer["flags"]
      if flags then         
         for _, flag in pairs(flags) do
            if flag == "mask" then
               fluid_wagon_mask = layer          
            end
         end
      end
   end
end

for _, wagon in pairs(data.raw["fluid-wagon"]) do
   -- some null checks just to be safe
   local pictures = wagon["pictures"]
   if not pictures then goto continue end
   local layers = pictures["layers"]
   if not layers then goto continue end
   
   local num_vanilla_matches = 0
   for _, layer in pairs(layers) do      
      -- ignore wagons that already have a mask layer
      local flags = layer["flags"]
      if flags then
         for _, flag in pairs(flags) do
            if flag == "mask" then goto continue end
         end
      else        
         -- disable runtime tint, required or else it will become translucent
         layer["apply_runtime_tint"] = false
         layer["hr_version"]["apply_runtime_tint"] = false
      end

      -- count matching vanilla graphics in the filenames table
      local vanilla_graphic_pattern = "__base__/graphics/entity/fluid%-wagon/fluid%-wagon%-.%.png"
      local filenames = layer["filenames"]
      if filenames then
         for _, filename in pairs(filenames) do
            if string.match(filename, vanilla_graphic_pattern) then
               num_vanilla_matches = num_vanilla_matches + 1
            end
         end
      end
   end

   -- there should have been 4 matches for the vanilla graphic
   if num_vanilla_matches < 4 then goto continue end

   -- all checks passed, add mask to this wagon
   table.insert(layers, fluid_wagon_mask)
   log("Added fluid wagon mask to wagon " .. wagon.name)

    ::continue::
end