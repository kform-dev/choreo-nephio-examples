def getSpec(self):
  return self.get("spec", {})

def getAddressFamily(self):
  spec = getSpec(self)
  return spec.get("addressFamily", "ipv4")

def getStatusPrefix(self):
  status = getStatus(self)
  return status.get("prefix", "")

def getSpecLabels(self):
   spec = getSpec(self)
   return spec.get("labels", {})

def getStatus(self):
  if "status" not in self:
    self["status"] = {}
  return self.get("status", {})

def setStatusPrefix(self, prefix):
  status = getStatus(self)
  status["prefix"] = prefix
  self["status"] = status
  return self

def getPrefixReqSpec(partition, network, prefixType, preficLength, addressFamily, labels):
  return {
    "partition": partition,
    "network": network,
    "prefixType": prefixType,
    "prefixLength": preficLength,
    "addressFamily": addressFamily,
    "labels": labels, 
  }

def getPrefixReq(name, namespace, spec):
  return {
    "apiVersion": "req.kuid.dev/v1alpha1",
    "kind": "Prefix",
    "metadata": {
        "name": name,
        "namespace": namespace,
    },
    "spec": spec,
  }

def listReadyPrefixRequests(selector, uid):
  resource = get_resource("req.kuid.dev/v1alpha1", "Prefix")
  rsp = client_list(resource["resource"], selector)
  if rsp["error"] != None:
    return None, False, "list prefixes.req.kuid.dev" + " err: " + rsp["error"]
  
  prefixReqs = []
  ready = True
  for prefixReq in rsp["resource"]["items"]:
    if is_conditionready(prefixReq, "Ready") != True:
      ready = False
      break
    ownerReferences = prefixReq["metadata"].get("ownerReferences", [])
    for ownerRef in ownerReferences:
      if ownerRef.get("uid", "") == uid:
        prefixReqs.append(prefixReq)     
  return prefixReqs, ready, None 