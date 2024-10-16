def getSpec(self):
  return self.get("spec", {})

def getSpecName(self):
  spec =  self.get("spec", {})
  return spec.get("name", {})

def getStatus(self):
  if "status" not in self:
    self["status"] = {}
  return self.get("status", {})

def setStatusName(self, name):
  status = getStatus(self)
  status["name"] = name
  self["status"] = status
  return self

def getNetworkReqSpec(name, partition, networkType, ipFamilyPolicy):
  spec = {
    "name": name,
    "partition": partition,
    "type": networkType,
    "ipFamilyPolicy": ipFamilyPolicy,
  }
  return spec

def getNetworkReq(name, namespace, spec):
  return {
    "apiVersion": "req.kuid.dev/v1alpha1",
    "kind": "Network",
    "metadata": {
        "name": name,
        "namespace": namespace,
    },
    "spec": spec,
  }
