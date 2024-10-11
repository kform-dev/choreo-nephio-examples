def getSpec(self):
  return self.get("spec", {})

def getSpecName(self):
  spec =  self.get("spec", {})
  return spec.get("name", {})