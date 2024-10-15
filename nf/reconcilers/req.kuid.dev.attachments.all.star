load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("req.kuid.dev.attachments.star", "setStatusPrefix", "setStatusVLAN")

finalizer = "req.kuid.dev.networks.all"
conditionType = "Ready"

def reconcile(self):
  #self is prefix req

  if getDeletionTimestamp(self) != None:
    rsp = client_delete()
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
    
    delFinalizer(self, finalizer)
    return reconcile_result(self, False, 0, conditionType, "", False)

  setFinalizer(self, finalizer)

  attachmentName = getName(self)
  last_segment = attachmentName.split('.')[-1] 
  if last_segment == "n3":
    setStatusPrefix(self, "ipv4", "192.1.0.0/24", "192.1.0.1")
    setStatusPrefix(self, "ipv6", "192:1::/64", "192:1::1")
    setStatusVLAN(self, 1)
  elif last_segment == "n4":
    setStatusPrefix(self, "ipv4", "192.2.0.0/24", "192.2.0.1")
    setStatusPrefix(self, "ipv6", "192:2::/64", "192:2::1")
    setStatusVLAN(self, 2)
  elif last_segment == "n6":
    setStatusPrefix(self, "ipv4", "192.3.0.0/24", "192.3.0.1")
    setStatusPrefix(self, "ipv6", "192:3::/64", "192:3::1")
    setStatusVLAN(self, 3)
  
  return reconcile_result(self, False, 0, conditionType, "", False)
