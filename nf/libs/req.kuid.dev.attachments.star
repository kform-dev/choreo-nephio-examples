def getSpec(self):
  return self.get("spec", {})


def getSpecCluster(self):
  spec = getSpec(self)
  return spec.get("cluster", "")

def getSpecInterface(self):
  spec = getSpec(self)
  return spec.get("interface", "")

def getSpecNetwork(self):
  spec = getSpec(self)
  return spec.get("network", "")

def getStatus(self):
  if "status" not in self:
    self["status"] = {}
  return self.get("status", {})

def getStatusAF(self, af):
  status = getStatus(self)
  return status.get(af)

def getStatusPrefixPerAF(self, af):
  statusPerAF = getStatusAF(self, af)
  if statusPerAF == None:
    return None
  return statusPerAF.get("prefixes", [])

def setStatusVLAN(self, vlan):
  status = getStatus(self)
  status["vlan"] = vlan
  self["status"] = status
  return self

def setStatusPrefix(self, af, newPrefix, defaultGateway):
  status = getStatus(self)
  if af not in status:
    status[af] = {"prefixes": []}

  prefixes = status[af]["prefixes"]
  found = False
  for prefix in prefixes:
    if prefix["prefix"] == newPrefix:
      if defaultGateway == "":
        prefix = remove_key(prefix, "defaultGateway")
      else:  
        prefix["defaultGateway"] = defaultGateway
      found = True
      break
  if not found:
    if defaultGateway == "":
       prefixes.append({
        "prefix": newPrefix,
      })
    else:
      prefixes.append({
        "prefix": newPrefix,
        "defaultGateway": defaultGateway,
      })
  return self

def getAttachmentReqSpec(itfceName, nodeName, clusterID, network, ipFamilyPolicy, attachementType):
  spec = {}
  for key, val in clusterID.items():
    spec[key] = val
  spec["interface"] = itfceName
  spec["node"] = nodeName
  spec["network"] = network
  spec["ipFamilyPolicy"] = ipFamilyPolicy
  if attachementType == "vlan":
    spec["vlanTagging"] = True
  return spec

def getAttachmentReq(name, namespace, spec):
  return {
    "apiVersion": "req.kuid.dev/v1alpha1",
    "kind": "Attachment",
    "metadata": {
        "name": name,
        "namespace": namespace,
    },
    "spec": spec,
  }
        
def remove_key(d, key):
    new_dict = {}
    for k, v in d.items():
        if k != key:
            new_dict[k] = v
    return new_dict

def listReadyAttachmentRequests(selector, uid):
  resource = get_resource("req.kuid.dev/v1alpha1", "Attachment")
  rsp = client_list(resource["resource"], selector)
  if rsp["error"] != None:
    return None, False, "list attachments.req.kuid.dev" + " err: " + rsp["error"]
  
  attachmentReqs = []
  ready = True
  for attachmentReq in rsp["resource"]["items"]:
    if is_conditionready(attachmentReq, "Ready") != True:
      ready = False
      break
    ownerReferences = attachmentReq["metadata"].get("ownerReferences", [])
    for ownerRef in ownerReferences:
      if ownerRef.get("uid", "") == uid:
        attachmentReqs.append(attachmentReq)    


  sortListWithKeyFn(attachmentReqs, lambda x: (x["spec"].get("interface", ""))) 
  return attachmentReqs, ready, None 


def sortListWithKeyFn(arr, key_func):
  for i in range(1, len(arr)):
    key_item = arr[i]
    key_value = key_func(key_item)
    # Insert key_item into the sorted sequence arr[0 ... i-1]
    inserted = False
    for j in range(i - 1, -1, -1):
      if key_func(arr[j]) > key_value:
        arr[j + 1] = arr[j]
      else:
        arr[j + 1] = key_item
        inserted = True
        break
    if not inserted:
      arr[0] = key_item
  return arr