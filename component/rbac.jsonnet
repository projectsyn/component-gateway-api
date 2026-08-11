// Aggregated cluster roles for the Gateway API groups
local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();

local gateway_crds =
  local manifests_dir = '%s/manifests/gateway-api' % inv.parameters._base_directory;
  local docs = std.flatMap(
    function(file)
      std.parseJson(kap.yaml_load_stream('%s/%s' % [ manifests_dir, file ])),
    kap.dir_files_list(manifests_dir)
  );
  std.filter(function(doc) doc.kind == 'CustomResourceDefinition', docs);

local rulesForScope(scope) =
  local crds = std.filter(function(crd) crd.spec.scope == scope, gateway_crds);
  local groups = std.set([ crd.spec.group for crd in crds ]);
  [
    {
      apiGroups: [ group ],
      resources: std.sort([
        crd.spec.names.plural
        for crd in crds
        if crd.spec.group == group
      ]),
    }
    for group in groups
  ];

local withVerbs(rules, verbs) = [ rule { verbs: verbs } for rule in rules ];

local readOnlyClusterScopedRules = withVerbs(rulesForScope('Cluster'), [ 'get', 'list', 'watch' ]);
local namespacedRules = rulesForScope('Namespaced');

local aggregatedViewRole = {
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRole',
  metadata: {
    labels: {
      'rbac.authorization.k8s.io/aggregate-to-cluster-reader': 'true',
      'rbac.authorization.k8s.io/aggregate-to-view': 'true',
    },
    name: 'networking-gatewayapi-aggregated-view',
  },
  rules: readOnlyClusterScopedRules + withVerbs(namespacedRules, [ 'get', 'list', 'watch' ]),
};

local aggregatedEditRole = {
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRole',
  metadata: {
    labels: {
      'rbac.authorization.k8s.io/aggregate-to-edit': 'true',
    },
    name: 'networking-gatewayapi-aggregated-edit',
  },
  rules: readOnlyClusterScopedRules + withVerbs(namespacedRules, [ '*' ]),
};

local aggregatedAdminRole = {
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRole',
  metadata: {
    labels: {
      'rbac.authorization.k8s.io/aggregate-to-admin': 'true',
    },
    name: 'networking-gatewayapi-aggregated-admin',
  },
  rules: readOnlyClusterScopedRules + withVerbs(namespacedRules, [ '*' ]),
};

{
  '30_aggregated_rbac': [
    aggregatedViewRole,
    aggregatedEditRole,
    aggregatedAdminRole,
  ],
}
