load("api.k8s.io.object.star", "getNamespace")

def getSpec(self):
  return self.get("spec", {})

def getNetwork(self):
  spec = getSpec(self)
  return spec.get("network", "default")

def getAttachmentType(self):
  spec = getSpec(self)
  return spec.get("attachmentType", "none")

def getIPFamilyPolicy(self):
  spec = getSpec(self)
  return spec.get("ipFamilyPolicy", "dual-stack")

def getInterface(name, namespace):
  resource = get_resource("req.nephio.org/v1alpha1", "Interface")
  rsp = client_get(name, namespace, resource["resource"])
  if rsp["error"] != None:
    return None, "interface.req.nephio.org/" + name + " err: " + rsp["error"]
  
  return rsp["resource"], None

def listInterfaces(selector):
  resource = get_resource("req.nephio.org/v1alpha1", "Interface")
  rsp = client_list(resource["resource"], selector)
  if rsp["error"] != None:
    return None, "list interfaces.req.nephio.org" + " err: " + rsp["error"]
  
  interfaces = []
  for itfce in rsp["resource"]["items"]:
    interfaces.append(itfce)
  return interfaces, None  

# itfces is a list of interface names
def getInterfaces(self, itfces):
  interfaces = []
  for itfce in itfces:
    itfce, err = getInterface(itfce, getNamespace(self))
    if err != None:
      return None, err
    interfaces.append(itfce)
  return interfaces, None
