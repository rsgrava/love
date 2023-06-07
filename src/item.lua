require("src/class")

Item = Class{}

function Item:init(defs)
    self.name = defs.name
    self.class = defs.class
    self.description = defs.description
end
