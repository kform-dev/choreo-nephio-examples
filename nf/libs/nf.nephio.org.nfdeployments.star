load("id.kuid.dev.ids.star", "getClusterKeys")

def getSpec(self):
  return self.get("spec", {})

def getNFDeploymentPartition(self):
  spec = getSpec(self)
  return spec.get("partition", "")

def getNFDeploymentProvider(self):
  spec = getSpec(self)
  return spec.get("provider", "")

def getNFDeploymentName(self):
  spec = getSpec(self)
  return spec.get("name", "")

def getNFDeploymentClusterID(self):
  clusterKeys = getClusterKeys()
  spec = getSpec(self)
  clusterID = {}
  for key, val in spec.items():
    if key in clusterKeys:
      clusterID[key] = val
  return clusterID
